! Copyright (C) 2009 Joe Groff, 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators kernel kernel.private
layouts make math math.private sbufs sequences sequences.private
strings ;
IN: math.parser

<PRIVATE
PRIMITIVE: (format-float) ( n fill width precision format locale -- byte-array )
PRIVATE>

: digit> ( ch -- n )
    {
        { [ dup CHAR: 9 <= ] [ CHAR: 0 -      dup  0 < [ drop 255 ] when ] }
        { [ dup CHAR: a <  ] [ CHAR: A 10 - - dup 10 < [ drop 255 ] when ] }
                             [ CHAR: a 10 - - dup 10 < [ drop 255 ] when ]
    } cond ; inline

: string>digits ( str -- digits )
    [ digit> ] B{ } map-as ; inline

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ; inline

ERROR: invalid-radix radix ;

<PRIVATE

! magnitude is used only for floats to avoid
! expensive computations when we know that
! the result will overflow/underflow.
! The computation of magnitude starts in
! number-parse and continues in float-parse.
TUPLE: number-parse
    { str read-only }
    { length fixnum read-only }
    { radix fixnum }
    { magnitude fixnum } ;

: <number-parse> ( str radix -- i number-parse n )
    [ 0 ] 2dip [ dup length ] dip 0 number-parse boa 0 ; inline

: (next-digit) ( i number-parse n digit-quot end-quot -- n/f )
    [ 2over length>> < ] 2dip
    [ [ 2over str>> nth-unsafe >fixnum [ 1 fixnum+fast ] 3dip ] prepose ] dip if ; inline

: require-next-digit ( i number-parse n quot -- n/f )
    [ 3drop f ] (next-digit) ; inline

: next-digit ( i number-parse n quot -- n/f )
    [ 2nip ] (next-digit) ; inline

: inc-magnitude ( number-parse -- number-parse' )
    [ 1 fixnum+fast ] change-magnitude ; inline

: ?inc-magnitude ( number-parse n -- number-parse' )
    zero? [ inc-magnitude ] unless ; inline

: (add-digit) ( number-parse n digit -- number-parse n' )
    [ dup radix>> ] [ * ] [ + ] tri* ; inline

: add-digit ( i number-parse n digit quot -- n/f )
    [ (add-digit) [ ?inc-magnitude ] keep ] dip next-digit ; inline

: add-exponent-digit ( i number-parse n digit quot -- n/f )
    [ (add-digit) ] dip next-digit ; inline

: digit-in-radix ( number-parse n char -- number-parse n digit ? )
    digit> pick radix>> over > ; inline

: ?make-ratio ( num denom/f -- ratio/f )
    ! don't use number= to allow 0. for "1/0."
    [ dup 0 = [ 2drop f ] [ / ] if ] [ drop f ] if* ; inline

TUPLE: float-parse
    { radix fixnum }
    { point fixnum }
    { exponent }
    { magnitude } ;

: inc-point-?dec-magnitude ( float-parse n -- float-parse' )
    zero? [ [ 1 fixnum-fast ] change-magnitude ] when
    [ 1 fixnum+fast ] change-point ; inline

: store-exponent ( float-parse n expt -- float-parse' n )
    swap [ >>exponent ] dip ; inline

: ?store-exponent ( float-parse n expt/f -- float-parse' n/f )
    [ store-exponent ] [ drop f ] if* ; inline

: pow-until ( base x -- base^x )
    [ 1 ] 2dip [
        dup odd? [ [ [ * ] keep ] [ 1 - ] bi* ] when
        [ sq ] [ 2/ ] bi*
    ] until-zero drop ; inline

: (pow) ( base x -- base^x )
    integer>fixnum-strict
    dup 0 >= [ pow-until ] [ [ recip ] [ neg ] bi* pow-until ] if ; inline

: add-mantissa-digit ( float-parse i number-parse n digit quot -- float-parse' n/f )
    [ (add-digit)
        dup [ inc-point-?dec-magnitude ] curry 3dip
    ] dip next-digit ; inline

! IEE754 doubles are in the range ]10^309,10^-324[,
! or expressed in base 2, ]2^1024, 2^-1074].
! We don't need those ranges to be accurate as long as we are
! excluding all the floats because they are used only to
! optimize when we know there will be an overflow/underflow
! We compare these numbers to the magnitude slot of float-parse,
! which has the following behavior:
! ... ; 0.0xxx -> -1; 0.xxx -> 0; x.xxx -> 1; xx.xxx -> 2; ...;
! Also, take some margin as the current float parsing algorithm
! does some rounding; For example,
! 0x1.0p-1074 is the smallest IE754 double, but floats down to
! 0x0.8p-1074 (excluded) are parsed as 0x1.0p-1074
CONSTANT: max-magnitude-10 309
CONSTANT: min-magnitude-10 -323
CONSTANT: max-magnitude-2 1027
CONSTANT: min-magnitude-2 -1074

: make-float-dec-exponent ( float-parse n/f -- float/f )
    over [ exponent>> ] [ magnitude>> ] bi +
    {
        { [ dup max-magnitude-10 > ] [ 3drop 1/0. ] }
        { [ dup min-magnitude-10 < ] [ 3drop 0.0 ] }
        [ drop
            [ [ radix>> ] [ point>> ] [ exponent>> ] tri - (pow) ]
            [ swap /f ] bi*
        ]
    } cond ; inline

: base2-digits ( digits radix -- digits' )
    {
        { 16 [ 4 * ] }
        { 8  [ 3 * ] }
        { 2  [ ] }
    } case ; inline

: base2-point ( float-parse -- point )
    [ point>> ] [ radix>> ] bi base2-digits ; inline

: base2-magnitude ( float-parse -- point )
    [ magnitude>> ] [ radix>> ] bi base2-digits ; inline

: make-float-bin-exponent ( float-parse n/f -- float/f )
    over [ exponent>> ] [ base2-magnitude ] bi +
    {
        { [ dup max-magnitude-2 > ] [ 3drop 1/0. ] }
        { [ dup min-magnitude-2 < ] [ 3drop 0.0 ] }
        [ drop
            [ [ drop 2 ] [ base2-point ] [ exponent>> ] tri - (pow) ]
            [ swap /f ] bi*
        ]
    } cond ; inline

: ?default-exponent ( float-parse n/f -- float-parse' n/f' )
    over exponent>> [
        over radix>> 10 = [ 0 store-exponent ] [ drop f ] if
    ] unless ; inline

: ?make-float ( float-parse n/f -- float/f )
    { float-parse object } declare
    ?default-exponent
    {
        { [ dup not ] [ 2drop f ] }
        { [ over radix>> 10 = ] [ make-float-dec-exponent ] }
        [ make-float-bin-exponent ]
    } cond ;

: bignum-?neg ( n -- -n )
    dup first-bignum bignum= [ drop most-negative-fixnum ] [ neg ] if ;

: fp-?neg ( n -- -n )
    double>bits 63 2^ bitor bits>double ;

: ?neg ( n/f -- -n/f )
    [
        {
            { [ dup bignum? ] [ bignum-?neg ] }
            { [ dup fp-nan? ] [ fp-?neg ] }
            [ neg ]
        } cond
    ] [ f ] if* ; inline

: ?pos ( n/f -- +n/f )
    dup fp-nan? [
        double>bits 63 2^ bitnot bitand bits>double
    ] when ; inline

: add-ratio? ( n/f -- ? )
    dup real? [ dup >integer number= not ] [ drop f ] if ;

: ?add-ratio ( m n/f -- m+n/f )
    dup add-ratio? [ + ] [ 2drop f ] if ; inline

: @abort ( i number-parse n x -- f )
    4drop f ; inline

: @split ( i number-parse n -- n i number-parse' n' )
    -rot 0 >>magnitude 0 ; inline

: @split-exponent ( i number-parse n -- n i number-parse' n' )
    -rot 10 >>radix 0 ; inline

: <float-parse> ( i number-parse n -- float-parse i number-parse n )
    [ drop nip [ radix>> ] [ magnitude>> ] bi [ 0 f ] dip float-parse boa ] 3keep ; inline

: if-skip ( char true false -- )
    pick ",_" member-eq? [ drop nip call ] [ nip call ] if ; inline

DEFER: @exponent-digit
DEFER: @mantissa-digit
DEFER: @denom-digit
DEFER: @num-digit
DEFER: @pos-digit
DEFER: @neg-digit

: @exponent-digit-or-punc ( float-parse i number-parse n char -- float-parse n/f )
    [ [ @exponent-digit ] require-next-digit ] [ @exponent-digit ] if-skip ; inline

: @exponent-digit ( float-parse i number-parse n char -- float-parse n/f )
    { float-parse fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @exponent-digit-or-punc ] add-exponent-digit ] [ @abort ] if ;

: @exponent-first-char ( float-parse i number-parse n char -- float-parse n/f )
    {
        { CHAR: - [ [ @exponent-digit ] require-next-digit ?neg ] }
        { CHAR: + [ [ @exponent-digit ] require-next-digit ?pos ] }
        [ @exponent-digit ?pos ]
    } case ; inline

: ->exponent ( float-parse i number-parse n -- float-parse' n/f )
    @split-exponent [ @exponent-first-char ] require-next-digit ?store-exponent ; inline

: exponent-char? ( number-parse n char -- number-parse n char ? )
    pick radix>> {
        { 10 [ dup "eE" member-eq? ] }
        [ drop dup "pP" member-eq? ]
    } case ; inline

: or-exponent ( i number-parse n char quot -- n/f )
    [ exponent-char? [ drop <float-parse> ->exponent ?make-float ] ] dip if ; inline

: or-mantissa->exponent ( float-parse i number-parse n char quot -- float-parse n/f )
    [ exponent-char? [ drop ->exponent ] ] dip if ; inline

: @mantissa-digit-or-punc ( float-parse i number-parse n char -- float-parse n/f )
    [ [ @mantissa-digit ] require-next-digit ] [ @mantissa-digit ] if-skip ; inline

: @mantissa-digit ( float-parse i number-parse n char -- float-parse n/f )
    { float-parse fixnum number-parse integer fixnum } declare
    [
        digit-in-radix
        [ [ @mantissa-digit-or-punc ] add-mantissa-digit ]
        [ @abort ] if
    ] or-mantissa->exponent ;

: ->mantissa ( i number-parse n -- n/f )
    <float-parse> [ @mantissa-digit ] next-digit ?make-float ; inline

: ->required-mantissa ( i number-parse n -- n/f )
    <float-parse> [ @mantissa-digit ] require-next-digit ?make-float ; inline

: @denom-digit-or-punc ( i number-parse n char -- n/f )
    [ [ @denom-digit ] require-next-digit ] [
        {
            { CHAR: . [ ->mantissa ] }
            [ [ @denom-digit ] or-exponent ]
        } case
    ] if-skip ; inline

: @denom-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @denom-digit-or-punc ] add-digit ] [ @abort ] if ;

: @denom-first-digit ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->mantissa ] }
        [ @denom-digit ]
    } case ; inline

: ->denominator ( i number-parse n -- n/f )
    { fixnum number-parse integer } declare
    @split [ @denom-first-digit ] require-next-digit ?make-ratio ;

: @num-digit-or-punc ( i number-parse n char -- n/f )
    [ [ @num-digit ] require-next-digit ] [
        {
            { CHAR: / [ ->denominator ] }
            [ @num-digit ]
        } case
    ] if-skip ; inline

: @num-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @num-digit-or-punc ] add-digit ] [ @abort ] if ;

: ->numerator ( i number-parse n -- n/f )
    { fixnum number-parse integer } declare
    @split [ @num-digit ] require-next-digit ?add-ratio ;

: @pos-digit-or-punc ( i number-parse n char -- n/f )
    [ [ @pos-digit ] require-next-digit ] [
        {
            { CHAR: + [ ->numerator ] }
            { CHAR: / [ ->denominator ] }
            { CHAR: . [ ->mantissa ] }
            [ [ @pos-digit ] or-exponent ]
        } case
    ] if-skip ; inline

: @pos-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @pos-digit-or-punc ] add-digit ] [ @abort ] if ;

: ->radix ( i number-parse n quot radix -- i number-parse n quot )
    [ >>radix ] curry 2dip ; inline

: with-radix-char ( i number-parse n radix-quot nonradix-quot -- n/f )
    [
        rot {
            { [ dup "bB" member-eq? ] [ 2drop  2 ->radix require-next-digit ] }
            { [ dup "oO" member-eq? ] [ 2drop  8 ->radix require-next-digit ] }
            { [ dup "xX" member-eq? ] [ 2drop 16 ->radix require-next-digit ] }
            [ nipd swap call ]
        } cond
    ] 2curry next-digit ; inline

: @pos-first-digit ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        { CHAR: 0 [ [ @pos-digit ] [ @pos-digit-or-punc ] with-radix-char ] }
        [ @pos-digit ]
    } case ; inline

: @neg-digit-or-punc ( i number-parse n char -- n/f )
    [ [ @neg-digit ] require-next-digit ] [
        {
            { CHAR: - [ ->numerator ] }
            { CHAR: / [ ->denominator ] }
            { CHAR: . [ ->mantissa ] }
            [ [ @neg-digit ] or-exponent ]
        } case
    ] if-skip ; inline

: @neg-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @neg-digit-or-punc ] add-digit ] [ @abort ] if ;

: @neg-first-digit ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        { CHAR: 0 [ [ @neg-digit ] [ @neg-digit-or-punc ] with-radix-char ] }
        [ @neg-digit ]
    } case ; inline

: @first-char ( i number-parse n char -- n/f )
    {
        { CHAR: - [ [ @neg-first-digit ] require-next-digit ?neg ] }
        { CHAR: + [ [ @pos-first-digit ] require-next-digit ?pos ] }
        [ @pos-first-digit ?pos ]
    } case ; inline

: @neg-first-digit-no-radix ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        [ @neg-digit ]
    } case ; inline

: @pos-first-digit-no-radix ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        [ @pos-digit ]
    } case ; inline

: @first-char-no-radix ( i number-parse n char -- n/f )
    {
        { CHAR: - [ [ @neg-first-digit-no-radix ] require-next-digit ?neg ] }
        { CHAR: + [ [ @pos-first-digit-no-radix ] require-next-digit ?pos ] }
        [ @pos-first-digit-no-radix ?pos ]
    } case ; inline

PRIVATE>

: string>number ( str -- n/f )
    10 <number-parse> [ @first-char ] require-next-digit ;

: base> ( str radix -- n/f )
    <number-parse> [ @first-char-no-radix ] require-next-digit ;

: bin> ( str -- n/f )  2 base> ; inline
: oct> ( str -- n/f )  8 base> ; inline
: dec> ( str -- n/f ) 10 base> ; inline
: hex> ( str -- n/f ) 16 base> ; inline

<PRIVATE

CONSTANT: TENS B{
    48 48 48 48 48 48 48 48 48 48 49 49 49 49 49 49 49 49 49 49
    50 50 50 50 50 50 50 50 50 50 51 51 51 51 51 51 51 51 51 51
    52 52 52 52 52 52 52 52 52 52 53 53 53 53 53 53 53 53 53 53
    54 54 54 54 54 54 54 54 54 54 55 55 55 55 55 55 55 55 55 55
    56 56 56 56 56 56 56 56 56 56 57 57 57 57 57 57 57 57 57 57
}

CONSTANT: ONES B{
    48 49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57
    48 49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57
    48 49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57
    48 49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57
    48 49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57
}

: (two-digit) ( num accum -- num' accum )
    [
        100 /mod [ TENS nth-unsafe ] [ ONES nth-unsafe ] bi
    ] dip [ push ] keep [ push ] keep ; inline

: (one-digit) ( num accum -- num' accum )
    [ 10 /mod CHAR: 0 + ] dip [ push ] keep ; inline

: (bignum>dec) ( num accum -- num' accum )
    [ over most-positive-fixnum > ]
    [ { bignum sbuf } declare (two-digit) ] while
    [ >fixnum ] dip ; inline

: (fixnum>dec) ( num accum -- num' accum )
    { fixnum sbuf } declare
    [ over 10 >= ] [ (two-digit) ] while
    [ over zero? ] [ (one-digit) ] until ; inline

GENERIC: (positive>dec) ( num -- str )

M: bignum (positive>dec)
    12 <sbuf> (bignum>dec) (fixnum>dec) "" like reverse! nip ; inline

: (count-digits) ( digits n -- digits' )
    {
        { [ dup 10 < ] [ drop ] }
        { [ dup 100 < ] [ drop 1 fixnum+fast ] }
        { [ dup 1,000 < ] [ drop 2 fixnum+fast ] }
        [
            dup 1,000,000,000,000 < [
                dup 100,000,000 < [
                    dup 1,000,000 < [
                        dup 10,000 < [
                            drop 3
                        ] [
                            100,000 >= 5 4 ?
                        ] if
                    ] [
                        10,000,000 >= 7 6 ?
                    ] if
                ] [
                    dup 10,000,000,000 < [
                        1,000,000,000 >= 9 8 ?
                    ] [
                        100,000,000,000 >= 11 10 ?
                    ] if
                ] if fixnum+fast
            ] [
                [ 12 fixnum+fast ] [ 1,000,000,000,000 /i ] bi*
                (count-digits)
            ] if
        ]
    } cond ; inline recursive

M: fixnum (positive>dec)
    1 over (count-digits) <sbuf> (fixnum>dec) "" like reverse! nip ; inline

: (positive>base) ( num radix -- str )
    dup 1 <= [ invalid-radix ] when
    [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
    reverse! ; inline

: positive>base ( num radix -- str )
    dup 10 = [ drop (positive>dec) ] [ (positive>base) ] if ; inline

PRIVATE>

GENERIC#: >base 1 ( n radix -- str )

: number>string ( n -- str ) 10 >base ; inline

: >bin ( n -- str ) 2 >base ; inline
: >oct ( n -- str ) 8 >base ; inline
: >hex ( n -- str ) 16 >base ; inline

ALIAS: >dec number>string

M: integer >base
    {
        { [ over 0 = ] [ 2drop "0" ] }
        { [ over 0 > ] [ positive>base ] }
        [ [ neg ] dip positive>base CHAR: - prefix ]
    } cond ;

M: ratio >base
    [ >fraction [ /mod ] keep ] [ [ >base ] curry tri@ ] bi*
    "/" glue over first-unsafe {
        { CHAR: 0 [ nip ] }
        { CHAR: - [ append ] }
        [ drop "+" glue ]
    } case ;

<PRIVATE

: (fix-float) ( str-no-exponent -- newstr )
    CHAR: . over member? [ ".0" append ] unless ; inline

: fix-float ( str exponent-char -- newstr )
    over index [
        cut [ (fix-float) ] dip append
    ] [ (fix-float) ] if* ; inline

: mantissa-expt-normalize ( mantissa expt -- mantissa' expt' )
    [ dup log2 52 swap - [ shift 52 2^ 1 - bitand ] [ 1022 + neg ] bi ]
    [ 1023 - ] if-zero ;

: mantissa-expt ( float -- mantissa expt )
    [ 52 2^ 1 - bitand ]
    [ -0.0 double>bits bitnot bitand -52 shift ] bi
    mantissa-expt-normalize ;

: bin-float-sign ( bits -- str )
    -0.0 double>bits bitand zero? "" "-" ? ;

: bin-float-value ( str size -- str' )
    CHAR: 0 pad-head [ CHAR: 0 = ] trim-tail
    [ "0" ] when-empty "1." prepend ;

: float>hex-value ( mantissa -- str )
    >hex 13 bin-float-value ;

: float>oct-value ( mantissa -- str )
    4 * >oct 18 bin-float-value ;

: float>bin-value ( mantissa -- str )
    >bin 52 bin-float-value ;

: bin-float-expt ( mantissa -- str )
    10 >base "p" prepend ;

: (bin-float>base) ( value-quot n -- str )
    double>bits
    [ bin-float-sign swap ] [
        mantissa-expt rot [ bin-float-expt ] bi*
    ] bi 3append ; inline

: bin-float>base ( n base -- str )
    {
        { 16 [ [ float>hex-value ] swap (bin-float>base) ] }
        { 8  [ [ float>oct-value ] swap (bin-float>base) ] }
        { 2  [ [ float>bin-value ] swap (bin-float>base) ] }
        [ invalid-radix ]
    } case ;

: format-string ( format -- format )
    0 suffix >byte-array ; foldable

: format-float ( n fill width precision format locale -- string )
    [
        [ format-string ] 4dip [ format-string ] bi@ (format-float)
        >string
    ] [
        "C" = [ [ "G" = ] [ "E" = ] bi or CHAR: E CHAR: e ? fix-float ]
        [ drop ] if
    ] 2bi ; inline

: float>base ( n radix -- str )
    {
        { 10 [ "" -1 16 "" "C" format-float ] }
        [ bin-float>base ]
    } case ; inline

PRIVATE>

M: float >base
    {
        { [ over fp-nan? ] [ drop fp-sign "-0/0." "0/0." ? ] }
        { [ over 1/0. =  ] [ 2drop "1/0." ] }
        { [ over -1/0. = ] [ 2drop "-1/0." ] }
        { [ over  0.0 fp-bitwise= ] [ 2drop  "0.0" ] }
        { [ over -0.0 fp-bitwise= ] [ 2drop "-0.0" ] }
        [ float>base ]
    } cond ;

: # ( n -- ) number>string % ; inline

: hex-string>bytes ( hex-string -- bytes )
    dup length 2/ <byte-array> [
        [
            [ digit> ] 2dip over even? [
                [ 16 * ] [ 2/ ] [ set-nth-unsafe ] tri*
            ] [
                [ 2/ ] [ [ + ] change-nth-unsafe ] bi*
            ] if
        ] curry each-index
    ] keep ;

: bytes>hex-string ( bytes -- hex-string )
    dup length 2 * CHAR: 0 <string> [
        [
            [ 16 /mod [ >digit ] bi@ ]
            [ 2 * dup 1 + ]
            [ [ set-nth-unsafe ] curry bi-curry@ bi* ] tri*
        ] curry each-index
    ] keep ;
