! Copyright (C) 2009 Joe Groff, 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators kernel kernel.private
layouts make math namespaces sbufs sequences sequences.private
splitting strings ;
IN: math.parser

: digit> ( ch -- n )
    {
        { [ dup CHAR: 9 <= ] [ CHAR: 0 -      dup  0 < [ drop 255 ] when ] }
        { [ dup CHAR: a <  ] [ CHAR: A 10 - - dup 10 < [ drop 255 ] when ] }
                             [ CHAR: a 10 - - dup 10 < [ drop 255 ] when ]
    } cond ; inline

ERROR: invalid-radix radix ;

<PRIVATE

TUPLE: number-parse
    { str read-only }
    { length fixnum read-only }
    { radix fixnum read-only } ;

: <number-parse> ( str radix -- i number-parse n )
    [ 0 ] 2dip
    [ dup length ] dip
    number-parse boa
    0 ; inline

: (next-digit) ( i number-parse n digit-quot end-quot -- n/f )
    [ 2over length>> < ] 2dip
    [ [ 2over str>> nth-unsafe >fixnum [ 1 + >fixnum ] 3dip ] prepose ] dip if ; inline

: require-next-digit ( i number-parse n quot -- n/f )
    [ 3drop f ] (next-digit) ; inline

: next-digit ( i number-parse n quot -- n/f )
    [ 2nip ] (next-digit) ; inline

: add-digit ( i number-parse n digit quot -- n/f )
    [ [ dup radix>> ] [ * ] [ + ] tri* ] dip next-digit ; inline

: digit-in-radix ( number-parse n char -- number-parse n digit ? )
    digit> pick radix>> over > ; inline

: ?make-ratio ( num denom/f -- ratio/f )
    [ / ] [ drop f ] if* ; inline

TUPLE: float-parse
    { radix read-only }
    { point read-only }
    { exponent read-only } ;

: inc-point ( float-parse -- float-parse' )
    [ radix>> ] [ point>> 1 + ] [ exponent>> ] tri float-parse boa ; inline

: store-exponent ( float-parse n expt -- float-parse' n )
    swap [ [ drop radix>> ] [ drop point>> ] [ nip ] 2tri float-parse boa ] dip ; inline

: ?store-exponent ( float-parse n expt/f -- float-parse' n/f )
    [ store-exponent ] [ drop f ] if* ; inline

: ((pow)) ( base x -- base^x )
    iota 1 rot [ nip * ] curry reduce ; inline

: (pow) ( base x -- base^x )
    dup 0 >= [ ((pow)) ] [ [ recip ] [ neg ] bi* ((pow)) ] if ; inline

: add-mantissa-digit ( float-parse i number-parse n digit quot -- float-parse' n/f )
    [ [ inc-point ] 4dip ] dip add-digit ; inline

: make-float-dec-exponent ( float-parse n/f -- float/f )
    [ [ radix>> ] [ point>> ] [ exponent>> ] tri - (pow) ] [ swap /f ] bi* ; inline

: make-float-bin-exponent ( float-parse n/f -- float/f )
    [ drop [ radix>> ] [ point>> ] bi (pow) ]
    [ nip swap /f ]
    [ drop 2.0 swap exponent>> (pow) * ] 2tri ; inline

: ?default-exponent ( float-parse n/f -- float-parse' n/f' )
    over exponent>> [
        over radix>> 10 =
        [ [ [ radix>> ] [ point>> ] bi 0 float-parse boa ] dip ]
        [ drop f ] if
    ] unless ; inline

: ?make-float ( float-parse n/f -- float/f )
    { float-parse object } declare
    ?default-exponent
    {
        { [ dup not ] [ 2drop f ] }
        { [ over radix>> 10 = ] [ make-float-dec-exponent ] }
        [ make-float-bin-exponent ]
    } cond ;

: ?neg ( n/f -- -n/f )
    [ neg ] [ f ] if* ; inline

: ?add-ratio ( m n/f -- m+n/f )
    dup ratio? [ + ] [ 2drop f ] if ; inline

: @abort ( i number-parse n x -- f )
    4drop f ; inline

: @split ( i number-parse n -- n i number-parse n' )
    -rot 0 ; inline

: @split-exponent ( i number-parse n -- n i number-parse' n' )
    -rot [ str>> ] [ length>> ] bi 10 number-parse boa 0 ; inline

: <float-parse> ( i number-parse n -- float-parse i number-parse n )
     [ drop nip radix>> 0 f float-parse boa ] 3keep ; inline

DEFER: @exponent-digit
DEFER: @mantissa-digit
DEFER: @denom-digit
DEFER: @num-digit
DEFER: @pos-digit
DEFER: @neg-digit

: @exponent-digit-or-punc ( float-parse i number-parse n char -- float-parse n/f )
    {
        { CHAR: , [ [ @exponent-digit ] require-next-digit ] }
        [ @exponent-digit ]
    } case ; inline

: @exponent-digit ( float-parse i number-parse n char -- float-parse n/f )
    { float-parse fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @exponent-digit-or-punc ] add-digit ] [ @abort ] if ;

: @exponent-first-char ( float-parse i number-parse n char -- float-parse n/f )
    {
        { CHAR: - [ [ @exponent-digit ] require-next-digit ?neg ] }
        { CHAR: + [ [ @exponent-digit ] require-next-digit ] }
        [ @exponent-digit ]
    } case ; inline

: ->exponent ( float-parse i number-parse n -- float-parse' n/f )
    @split-exponent [ @exponent-first-char ] require-next-digit ?store-exponent ; inline

: exponent-char? ( number-parse n char -- number-parse n char ? )
    3dup nip swap radix>> {
        { 10 [ [ CHAR: e CHAR: E ] dip [ = ] curry either? ] }
        [ drop [ CHAR: p CHAR: P ] dip [ = ] curry either? ]
    } case ; inline

: or-exponent ( i number-parse n char quot -- n/f )
    [ exponent-char? [ drop <float-parse> ->exponent ?make-float ] ] dip if ; inline

: or-mantissa->exponent ( float-parse i number-parse n char quot -- float-parse n/f )
    [ exponent-char? [ drop ->exponent ] ] dip if ; inline

: @mantissa-digit-or-punc ( float-parse i number-parse n char -- float-parse n/f )
    {
        { CHAR: , [ [ @mantissa-digit ] require-next-digit ] }
        [ @mantissa-digit ]
    } case ; inline

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
    {
        { CHAR: , [ [ @denom-digit ] require-next-digit ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @denom-digit ] or-exponent ]
    } case ; inline

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
    {
        { CHAR: , [ [ @num-digit ] require-next-digit ] }
        { CHAR: / [ ->denominator ] }
        [ @num-digit ]
    } case ; inline

: @num-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @num-digit-or-punc ] add-digit ] [ @abort ] if ;

: ->numerator ( i number-parse n -- n/f )
    { fixnum number-parse integer } declare
    @split [ @num-digit ] require-next-digit ?add-ratio ;

: @pos-digit-or-punc ( i number-parse n char -- n/f )
    {
        { CHAR: , [ [ @pos-digit ] require-next-digit ] }
        { CHAR: + [ ->numerator ] }
        { CHAR: / [ ->denominator ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @pos-digit ] or-exponent ]
    } case ; inline

: @pos-digit ( i number-parse n char -- n/f )
    { fixnum number-parse integer fixnum } declare
    digit-in-radix [ [ @pos-digit-or-punc ] add-digit ] [ @abort ] if ;

: (->radix) ( number-parse radix -- number-parse' )
    [ [ str>> ] [ length>> ] bi ] dip number-parse boa ; inline

: ->radix ( i number-parse n quot radix -- i number-parse n quot )
    [ (->radix) ] curry 2dip ; inline

: with-radix-char ( i number-parse n radix-quot nonradix-quot -- n/f )
    [
        rot {
            { CHAR: b [ drop  2 ->radix require-next-digit ] }
            { CHAR: o [ drop  8 ->radix require-next-digit ] }
            { CHAR: x [ drop 16 ->radix require-next-digit ] }
            { f       [ 3drop 2drop 0 ] }
            [ [ drop ] 2dip swap call ]
        } case
    ] 2curry next-digit ; inline

: @pos-first-digit ( i number-parse n char -- n/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        { CHAR: 0 [ [ @pos-digit ] [ @pos-digit-or-punc ] with-radix-char ] }
        [ @pos-digit ]
    } case ; inline

: @neg-digit-or-punc ( i number-parse n char -- n/f )
    {
        { CHAR: , [ [ @neg-digit ] require-next-digit ] }
        { CHAR: - [ ->numerator ] }
        { CHAR: / [ ->denominator ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @neg-digit ] or-exponent ]
    } case ; inline

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
        { CHAR: + [ [ @pos-first-digit ] require-next-digit ] }
        [ @pos-first-digit ]
    } case ; inline

: @first-char-no-radix ( i number-parse n char -- n/f ) 
    {
        { CHAR: - [ [ @neg-digit ] require-next-digit ?neg ] }
        { CHAR: + [ [ @pos-digit ] require-next-digit ] }
        [ @pos-digit ]
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

: string>digits ( str -- digits )
    [ digit> ] B{ } map-as ; inline

<PRIVATE

: (digits>integer) ( valid? accum digit radix -- valid? accum )
    2dup < [ swapd * + ] [ 4drop f 0 ] if ; inline

: each-digit ( seq radix quot -- n/f )
    [ t 0 ] 3dip curry each swap [ drop f ] unless ; inline

PRIVATE>

: digits>integer ( seq radix -- n/f )
    [ (digits>integer) ] each-digit ; inline

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ; inline

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

: (positive>dec) ( num -- str )
    3 <sbuf> (bignum>dec) (fixnum>dec) "" like reverse! nip ; inline

: (positive>base) ( num radix -- str )
    dup 1 <= [ invalid-radix ] when
    [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
    reverse! ; inline

: positive>base ( num radix -- str )
    dup 10 = [ drop (positive>dec) ] [ (positive>base) ] if ; inline

PRIVATE>

GENERIC# >base 1 ( n radix -- str )

: number>string ( n -- str ) 10 >base ; inline
: >bin ( n -- str ) 2 >base ; inline
: >oct ( n -- str ) 8 >base ; inline
: >hex ( n -- str ) 16 >base ; inline

<PRIVATE

SYMBOL: radix
SYMBOL: negative?

: sign ( -- str ) negative? get "-" "+" ? ;

: with-radix ( radix quot -- )
    radix swap with-variable ; inline

: (>base) ( n -- str ) radix get positive>base ;

PRIVATE>

M: integer >base
    over 0 = [
        2drop "0"
    ] [
        over 0 > [
            positive>base
        ] [
            [ neg ] dip positive>base CHAR: - prefix
        ] if
    ] if ;

M: ratio >base
    [
        dup 0 < negative? set
        abs 1 /mod
        [ [ "" ] [ (>base) sign append ] if-zero ]
        [
            [ numerator (>base) ]
            [ denominator (>base) ] bi
            "/" glue
        ] bi* append
        negative? get [ CHAR: - prefix ] when
    ] with-radix ;

: fix-float ( str -- newstr )
    {
        {
            [ CHAR: e over member? ]
            [ "e" split1 [ fix-float "e" ] dip 3append ]
        } {
            [ CHAR: . over member? ]
            [ ]
        }
        [ ".0" append ]
    } cond ;

<PRIVATE

: mantissa-expt-normalize ( mantissa expt -- mantissa' expt' )
    [ dup log2 52 swap - [ shift 52 2^ 1 - bitand ] [ 1022 + neg ] bi ]
    [ 1023 - ] if-zero ;

: mantissa-expt ( float -- mantissa expt )
    [ 52 2^ 1 - bitand ]
    [ -0.0 double>bits bitnot bitand -52 shift ] bi
    mantissa-expt-normalize ;

: float>hex-sign ( bits -- str )
    -0.0 double>bits bitand zero? "" "-" ? ;

: float>hex-value ( mantissa -- str )
    >hex 13 CHAR: 0 pad-head [ CHAR: 0 = ] trim-tail
    [ "0" ] when-empty "1." prepend ;

: float>hex-expt ( mantissa -- str )
    10 >base "p" prepend ;

: float>hex ( n -- str )
    double>bits
    [ float>hex-sign ] [
        mantissa-expt [ float>hex-value ] [ float>hex-expt ] bi*
    ] bi 3append ;

: format-float ( n format -- string )
    0 suffix >byte-array (format-float)
    dup [ 0 = ] find drop head >string
    fix-float ;

: float>base ( n radix -- str )
    {
        { 16 [ float>hex ] }
        { 10 [ "%.16g" format-float ] }
        [ invalid-radix ]
    } case ; inline

PRIVATE>

: float>string ( n -- str )
    10 float>base ; inline

M: float >base
    {
        { [ over fp-nan? ] [ 2drop "0/0." ] }
        { [ over 1/0. =  ] [ 2drop "1/0." ] }
        { [ over -1/0. = ] [ 2drop "-1/0." ] }
        { [ over  0.0 fp-bitwise= ] [ 2drop  "0.0" ] }
        { [ over -0.0 fp-bitwise= ] [ 2drop "-0.0" ] }
        [ float>base ]
    } cond ;

: # ( n -- ) number>string % ; inline
