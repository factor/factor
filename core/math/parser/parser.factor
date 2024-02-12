! Copyright (C) 2009 Joe Groff, 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators kernel kernel.private
layouts make math math.order math.private sbufs sequences
sequences.private strings ;
IN: math.parser

<PRIVATE
PRIMITIVE: (format-float) ( n fill width precision format locale -- byte-array )

: format-string ( format -- format )
    0 suffix >byte-array ; foldable

! Used as primitive for formatting vocabulary
: format-float ( n fill width precision format locale -- string )
    [ format-string ] 4dip
    [ format-string ] bi@
    (format-float) >string ; inline

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

: two-digit ( num accum -- num' accum )
    [
        100 /mod [ TENS nth-unsafe ] [ ONES nth-unsafe ] bi
    ] dip [ push ] keep [ push ] keep ; inline

: one-digit ( num accum -- num' accum )
    [ 10 /mod CHAR: 0 + ] dip [ push ] keep ; inline

: bignum>dec ( num accum -- num' accum )
    [ over most-positive-fixnum > ]
    [ { bignum sbuf } declare two-digit ] while
    [ >fixnum ] dip ; inline

: fixnum>dec ( num accum -- num' accum )
    { fixnum sbuf } declare
    [ over 10 >= ] [ two-digit ] while
    [ over zero? ] [ one-digit ] until ; inline

GENERIC: positive>dec ( num -- str )

M: bignum positive>dec
    12 <sbuf> bignum>dec fixnum>dec "" like reverse! nip ; inline

: count-digits ( digits n -- digits' )
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
                count-digits
            ] if
        ]
    } cond ; inline recursive

M: fixnum positive>dec
    1 over count-digits <sbuf> fixnum>dec "" like reverse! nip ; inline

: positive>base ( num radix -- str )
    {
        { 10 [ positive>dec ] }
        [
            dup 1 <= [ invalid-radix ] when
            [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
            reverse!
        ]
    } case ;

PRIVATE>

GENERIC#: >base 1 ( n radix -- str )

: >bin ( n -- str ) 2 >base ; inline
: >oct ( n -- str ) 8 >base ; inline
: >dec ( n -- str ) 10 >base ; inline
: >hex ( n -- str ) 16 >base ; inline

ALIAS: number>string >dec

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

: mantissa-expt-normalize ( mantissa expt -- mantissa' expt' )
    [ dup log2 52 swap - [ shift 52 2^ 1 - bitand ] [ 1022 + neg ] bi ]
    [ 1023 - ] if-zero ;

: (mantissa-expt) ( bits -- mantissa expt )
    [ 52 2^ 1 - bitand ]
    [ -0.0 double>bits bitnot bitand -52 shift ] bi ; inline

: mantissa-expt ( bits -- mantissa expt )
    (mantissa-expt) mantissa-expt-normalize ;

: float-sign ( bits -- str ) 63 bit? "-" "" ? ; inline

: bin-float-value ( str size -- str' )
    CHAR: 0 pad-head [ CHAR: 0 = ] trim-tail
    [ "0" ] when-empty "1." prepend ;

: float>hex-value ( mantissa -- str )
    >hex 13 bin-float-value ;

: float>oct-value ( mantissa -- str )
    4 * >oct 18 bin-float-value ;

: float>bin-value ( mantissa -- str )
    >bin 52 bin-float-value ;

: bin-float-expt ( exponent -- str )
    >dec "p" prepend ;

: (bin-float>base) ( value-quot n -- str )
    double>bits
    [ float-sign swap ] [
        mantissa-expt rot [ bin-float-expt ] bi*
    ] bi 3append ; inline

: bin-float>base ( n base -- str )
    {
        { 16 [ [ float>hex-value ] swap (bin-float>base) ] }
        { 8  [ [ float>oct-value ] swap (bin-float>base) ] }
        { 2  [ [ float>bin-value ] swap (bin-float>base) ] }
        [ invalid-radix ]
    } case ;

! Dragonbox algorithm

: ⌊nlog10_2⌋ ( n -- m ) 315653 * -20 shift ; inline

: ⌊nlog2_10⌋ ( n -- m ) 1741647 * -19 shift ; inline

: 1000/ ( n -- m ) 2361183241434822607 * -71 shift ; inline

: ⌊nlog10_2-log10_4/3⌋ ( n -- m ) 631305 * 261663 - -21 shift ; inline

: 100/mod ( n -- t ρ≠0? )
    656 * [ -16 shift ] [ 16 2^ 1 - bitand 656 >= ] bi ; inline

: >double< ( n -- s F E )
    double>bits [ float-sign ] [ (mantissa-expt) ] bi ; inline

: mantissa-expt-normalize* ( F E -- F' E' )
    [ -1022 ] [ [ 52 2^ bitor ] [ 1023 - ] bi* ] if-zero 52 - ; inline

: shorter-interval? ( F E -- ? )
    [ zero? ] [ 1 > ] bi* and ; inline

: k ( E -- k ) ⌊nlog10_2⌋ neg 2 + ; inline

CONSTANT: lookup-table {
0xc795830d75038c1dd59df5b9ef6a2418 0xf97ae3d0d2446f254b0573286b44ad1e
0x9becce62836ac5774ee367f9430aec33 0xc2e801fb244576d5229c41f793cda740
0xf3a20279ed56d48a6b43527578c11110 0x9845418c345644d6830a13896b78aaaa
0xbe5691ef416bd60c23cc986bc656d554 0xedec366b11c6cb8f2cbfbe86b7ec8aa9
0x94b3a202eb1c3f397bf7d71432f3d6aa 0xb9e08a83a5e34f07daf5ccd93fb0cc54
0xe858ad248f5c22c9d1b3400f8f9cff69 0x91376c36d99995be23100809b9c21fa2
0xb58547448ffffb2dabd40a0c2832a78b 0xe2e69915b3fff9f916c90c8f323f516d
0x8dd01fad907ffc3bae3da7d97f6792e4 0xb1442798f49ffb4a99cd11cfdf41779d
0xdd95317f31c7fa1d40405643d711d584 0x8a7d3eef7f1cfc52482835ea666b2573
0xad1c8eab5ee43b66da3243650005eed0 0xd863b256369d4a4090bed43e40076a83
0x873e4f75e2224e685a7744a6e804a292 0xa90de3535aaae202711515d0a205cb37
0xd3515c2831559a830d5a5b44ca873e04 0x8412d9991ed58091e858790afe9486c3
0xa5178fff668ae0b6626e974dbe39a873 0xce5d73ff402d98e3fb0a3d212dc81290
0x80fa687f881c7f8e7ce66634bc9d0b9a 0xa139029f6a239f721c1fffc1ebc44e81
0xc987434744ac874ea327ffb266b56221 0xfbe9141915d7a9224bf1ff9f0062baa9
0x9d71ac8fada6c9b56f773fc3603db4aa 0xc4ce17b399107c22cb550fb4384d21d4
0xf6019da07f549b2b7e2a53a146606a49 0x99c102844f94e0fb2eda7444cbfc426e
0xc0314325637a1939fa911155fefb5309 0xf03d93eebc589f88793555ab7eba27cb
0x96267c7535b763b54bc1558b2f3458df 0xbbb01b9283253ca29eb1aaedfb016f17
0xea9c227723ee8bcb465e15a979c1cadd 0x92a1958a7675175f0bfacd89ec191eca
0xb749faed14125d36cef980ec671f667c 0xe51c79a85916f48482b7e12780e7401b
0x8f31cc0937ae58d2d1b2ecb8b0908811 0xb2fe3f0b8599ef07861fa7e6dcb4aa16
0xdfbdcece67006ac967a791e093e1d49b 0x8bd6a141006042bde0c8bb2c5c6d24e1
0xaecc49914078536d58fae9f773886e19 0xda7f5bf590966848af39a475506a899f
0x888f99797a5e012d6d8406c952429604 0xaab37fd7d8f58178c8e5087ba6d33b84
0xd5605fcdcf32e1d6fb1e4a9a90880a65 0x855c3be0a17fcd265cf2eea09a550680
0xa6b34ad8c9dfc06ff42faa48c0ea481f 0xd0601d8efc57b08bf13b94daf124da27
0x823c12795db6ce5776c53d08d6b70859 0xa2cb1717b52481ed54768c4b0c64ca6f
0xcb7ddcdda26da268a9942f5dcf7dfd0a 0xfe5d54150b090b02d3f93b35435d7c4d
0x9efa548d26e5a6e1c47bc5014a1a6db0 0xc6b8e9b0709f109a359ab6419ca1091c
0xf867241c8cc6d4c0c30163d203c94b63 0x9b407691d7fc44f879e0de63425dcf1e
0xc21094364dfb5636985915fc12f542e5 0xf294b943e17a2bc43e6f5b7b17b2939e
0x979cf3ca6cec5b5aa705992ceecf9c43 0xbd8430bd0827723150c6ff782a838354
0xece53cec4a314ebda4f8bf5635246429 0x940f4613ae5ed136871b7795e136be9a
0xb913179899f6858428e2557b59846e40 0xe757dd7ec07426e5331aeada2fe589d0
0x9096ea6f3848984f3ff0d2c85def7622 0xb4bca50b065abe630fed077a756b53aa
0xe1ebce4dc7f16dfbd3e8495912c62895 0x8d3360f09cf6e4bd64712dd7abbbd95d
0xb080392cc4349decbd8d794d96aacfb4 0xdca04777f541c567ecf0d7a0fc5583a1
0x89e42caaf9491b60f41686c49db57245 0xac5d37d5b79b6239311c2875c522ced6
0xd77485cb25823ac77d633293366b828c 0x86a8d39ef77164bcae5dff9c02033198
0xa8530886b54dbdebd9f57f830283fdfd 0xd267caa862a12d66d072df63c324fd7c
0x8380dea93da4bc604247cb9e59f71e6e 0xa46116538d0deb7852d9be85f074e609
0xcd795be87051665667902e276c921f8c 0x806bd9714632dff600ba1cd8a3db53b7
0xa086cfcd97bf97f380e8a40eccd228a5 0xc8a883c0fdaf7df06122cd128006b2ce
0xfad2a4b13d1b5d6c796b805720085f82 0x9cc3a6eec6311a63cbe3303674053bb1
0xc3f490aa77bd60fcbedbfc4411068a9d 0xf4f1b4d515acb93bee92fb5515482d45
0x991711052d8bf3c5751bdd152d4d1c4b 0xbf5cd54678eef0b6d262d45a78a0635e
0xef340a98172aace486fb897116c87c35 0x9580869f0e7aac0ed45d35e6ae3d4da1
0xbae0a846d21957128974836059cca10a 0xe998d258869facd72bd1a438703fc94c
0x91ff83775423cc067b6306a34627ddd0 0xb67f6455292cbf081a3bc84c17b1d543
0xe41f3d6a7377eeca20caba5f1d9e4a94 0x8e938662882af53e547eb47b7282ee9d
0xb23867fb2a35b28de99e619a4f23aa44 0xdec681f9f4c31f316405fa00e2ec94d5
0x8b3c113c38f9f37ede83bc408dd3dd05 0xae0b158b4738705e9624ab50b148d446
0xd98ddaee19068c763badd624dd9b0958 0x87f8a8d4cfa417c9e54ca5d70a80e5d7
0xa9f6d30a038d1dbc5e9fcf4ccd211f4d 0xd47487cc8470652b7647c32000696720
0x84c8d4dfd2c63f3b29ecd9f40041e074 0xa5fb0a17c777cf09f468107100525891
0xcf79cc9db955c2cc7182148d4066eeb5 0x81ac1fe293d599bfc6f14cd848405531
0xa21727db38cb002fb8ada00e5a506a7d 0xca9cf1d206fdc03ba6d90811f0e4851d
0xfd442e4688bd304a908f4a166d1da664 0x9e4a9cec15763e2e9a598e4e043287ff
0xc5dd44271ad3cdba40eff1e1853f29fe 0xf7549530e188c128d12bee59e68ef47d
0x9a94dd3e8cf578b982bb74f8301958cf 0xc13a148e3032d6e7e36a52363c1faf02
0xf18899b1bc3f8ca1dc44e6c3cb279ac2 0x96f5600f15a7b7e529ab103a5ef8c0ba
0xbcb2b812db11a5de7415d448f6b6f0e8 0xebdf661791d60f56111b495b3464ad22
0x936b9fcebb25c995cab10dd900beec35 0xb84687c269ef3bfb3d5d514f40eea743
0xe65829b3046b0afa0cb4a5a3112a5113 0x8ff71a0fe2c2e6dc47f0e785eaba72ac
0xb3f4e093db73a09359ed216765690f57 0xe0f218b8d25088b8306869c13ec3532d
0x8c974f73837255731e414218c73a13fc 0xafbd2350644eeacfe5d1929ef90898fb
0xdbac6c247d62a583df45f746b74abf3a 0x894bc396ce5da7726b8bba8c328eb784
0xab9eb47c81f5114f066ea92f3f326565 0xd686619ba27255a2c80a537b0efefebe
0x8613fd0145877585bd06742ce95f5f37 0xa798fc4196e952e72c48113823b73705
0xd17f3b51fca3a7a0f75a15862ca504c6 0x82ef85133de648c49a984d73dbe722fc
0xa3ab66580d5fdaf5c13e60d0d2e0ebbb 0xcc963fee10b7d1b3318df905079926a9
0xffbbcfe994e5c61ffdf17746497f7053 0x9fd561f1fd0f9bd3feb6ea8bedefa634
0xc7caba6e7c5382c8fe64a52ee96b8fc1 0xf9bd690a1b68637b3dfdce7aa3c673b1
0x9c1661a651213e2d06bea10ca65c084f 0xc31bfa0fe5698db8486e494fcff30a63
0xf3e2f893dec3f1265a89dba3c3efccfb 0x986ddb5c6b3a76b7f89629465a75e01d
0xbe89523386091465f6bbb397f1135824 0xee2ba6c0678b597f746aa07ded582e2d
0x94db483840b717efa8c2a44eb4571cdd 0xba121a4650e4ddeb92f34d62616ce414
0xe896a0d7e51e156677b020baf9c81d18 0x915e2486ef32cd600ace1474dc1d122f
0xb5b5ada8aaff80b80d819992132456bb 0xe3231912d5bf60e610e1fff697ed6c6a
0x8df5efabc5979c8fca8d3ffa1ef463c2 0xb1736b96b6fd83b3bd308ff8a6b17cb3
0xddd0467c64bce4a0ac7cb3f6d05ddbdf 0x8aa22c0dbef60ee46bcdf07a423aa96c
0xad4ab7112eb3929d86c16c98d2c953c7 0xd89d64d57a607744e871c7bf077ba8b8
0x87625f056c7c4a8b11471cd764ad4973 0xa93af6c6c79b5d2dd598e40d3dd89bd0
0xd389b478798234794aff1d108d4ec2c4 0x843610cb4bf160cbcedf722a585139bb
0xa54394fe1eedb8fec2974eb4ee658829 0xce947a3da6a9273e733d226229feea33
0x811ccc668829b8870806357d5a3f5260 0xa163ff802a3426a8ca07c2dcb0cf26f8
0xc9bcff6034c13052fc89b393dd02f0b6 0xfc2c3f3841f17c67bbac2078d443ace3
0x9d9ba7832936edc0d54b944b84aa4c0e 0xc5029163f384a9310a9e795e65d4df12
0xf64335bcf065d37d4d4617b5ff4a16d6 0x99ea0196163fa42e504bced1bf8e4e46
0xc06481fb9bcf8d39e45ec2862f71e1d7 0xf07da27a82c370885d767327bb4e5a4d
0x964e858c91ba26553a6a07f8d510f870 0xbbe226efb628afea890489f70a55368c
0xeadab0aba3b2dbe52b45ac74ccea842f 0x92c8ae6b464fc96f3b0b8bc90012929e
0xb77ada0617e3bbcb09ce6ebb40173745 0xe55990879ddcaabdcc420a6a101d0516
0x8f57fa54c2a9eab69fa946824a12232e 0xb32df8e9f354656447939822dc96abfa
0xdff9772470297ebd59787e2b93bc56f8 0x8bfbea76c619ef3657eb4edb3c55b65b
0xaefae51477a06b03ede622920b6b23f2 0xdab99e59958885c4e95fab368e45ecee
0x88b402f7fd75539b11dbcb0218ebb415 0xaae103b5fcd2a881d652bdc29f26a11a
0xd59944a37c0752a24be76d3346f04960 0x857fcae62d8493a56f70a4400c562ddc
0xa6dfbd9fb8e5b88ecb4ccd500f6bb953 0xd097ad07a71f26b27e2000a41346a7a8
0x825ecc24c873782f8ed400668c0c28c9 0xa2f67f2dfa90563b728900802f0f32fb
0xcbb41ef979346bca4f2b40a03ad2ffba 0xfea126b7d78186bce2f610c84987bfa9
0x9f24b832e6b0f4360dd9ca7d2df4d7ca 0xc6ede63fa05d314391503d1c79720dbc
0xf8a95fcf88747d9475a44c6397ce912b 0x9b69dbe1b548ce7cc986afbe3ee11abb
0xc24452da229b021bfbe85badce996169 0xf2d56790ab41c2a2fae27299423fb9c4
0x97c560ba6b0919a5dccd879fc967d41b 0xbdb6b8e905cb600f5400e987bbc1c921
0xed246723473e3813290123e9aab23b69 0x9436c0760c86e30bf9a0b6720aaf6522
0xb94470938fa89bcef808e40e8d5b3e6a 0xe7958cb87392c2c2b60b1d1230b20e05
0x90bd77f3483bb9b9b1c6f22b5e6f48c3 0xb4ecd5f01a4aa8281e38aeb6360b1af4
0xe2280b6c20dd523225c6da63c38de1b1 0x8d590723948a535f579c487e5a38ad0f
0xb0af48ec79ace8372d835a9df0c6d852 0xdcdb1b2798182244f8e431456cf88e66
0x8a08f0f8bf0f156b1b8e9ecb641b5900 0xac8b2d36eed2dac5e272467e3d222f40
0xd7adf884aa8791775b0ed81dcc6abb10 0x86ccbb52ea94baea98e947129fc2b4ea
0xa87fea27a539e9a53f2398d747b36225 0xd29fe4b18e88640e8eec7f0d19a03aae
0x83a3eeeef9153e891953cf68300424ad 0xa48ceaaab75a8e2b5fa8c3423c052dd8
0xcdb02555653131b63792f412cb06794e 0x808e17555f3ebf11e2bbd88bbee40bd1
0xa0b19d2ab70e6ed65b6aceaeae9d0ec5 0xc8de047564d20a8bf245825a5a445276
0xfb158592be068d2eeed6e2f0f0d56713 0x9ced737bb6c4183d55464dd69685606c
0xc428d05aa4751e4caa97e14c3c26b887 0xf53304714d9265dfd53dd99f4b3066a9
0x993fe2c6d07b7fabe546a8038efe402a 0xbf8fdb78849a5f96de98520472bdd034
0xef73d256a5c0f77c963e66858f6d4441 0x95a8637627989aaddde7001379a44aa9
0xbb127c53b17ec1595560c018580d5d53 0xe9d71b689dde71afaab8f01e6e10b4a7
0x9226712162ab070dcab3961304ca70e9 0xb6b00d69bb55c8d13d607b97c5fd0d23
0xe45c10c42a2b3b058cb89a7db77c506b 0x8eb98a7a9a5b04e377f3608e92adb243
0xb267ed1940f1c61c55f038b237591ed4 0xdf01e85f912e37a36b6c46dec52f6689
0x8b61313bbabce2c62323ac4b3b3da016 0xae397d8aa96c1b77abec975e0a0d081b
0xd9c7dced53c7225596e7bd358c904a22 0x881cea14545c75757e50d64177da2e55
0xaa242499697392d2dde50bd1d5d0b9ea 0xd4ad2dbfc3d07787955e4ec64b44e865
0x84ec3c97da624ab4bd5af13bef0b113f 0xa6274bbdd0fadd61ecb1ad8aeacdd58f
0xcfb11ead453994ba67de18eda5814af3 0x81ceb32c4b43fcf480eacf948770ced8
0xa2425ff75e14fc31a1258379a94d028e 0xcad2f7f5359a3b3e096ee45813a04331
0xfd87b5f28300ca0d8bca9d6e188853fd 0x9e74d1b791e07e48775ea264cf55347e
0xc612062576589dda95364afe032a819e 0xf79687aed3eec5513a83ddbd83f52205
0x9abe14cd44753b52c4926a9672793543 0xc16d9a0095928a2775b7053c0f178294
0xf1c90080baf72cb15324c68b12dd6339 0x971da05074da7beed3f6fc16ebca5e04
0xbce5086492111aea88f4bb1ca6bcf585 0xec1e4a7db69561a52b31e9e3d06c32e6
0x9392ee8e921d5d073aff322e62439fd0 0xb877aa3236a4b44909befeb9fad487c3
0xe69594bec44de15b4c2ebe687989a9b4 0x901d7cf73ab0acd90f9d37014bf60a11
0xb424dc35095cd80f538484c19ef38c95 0xe12e13424bb40e132865a5f206b06fba
0x8cbccc096f5088cbf93f87b7442e45d4 0xafebff0bcb24aafef78f69a51539d749
0xdbe6fecebdedd5beb573440e5a884d1c 0x89705f4136b4a59731680a88f8953031
0xabcc77118461cefcfdc20d2b36ba7c3e 0xd6bf94d5e57a42bc3d32907604691b4d
0x8637bd05af6c69b5a63f9a49c2c1b110 0xa7c5ac471b4784230fcf80dc33721d54
0xd1b71758e219652bd3c36113404ea4a9 0x83126e978d4fdf3b645a1cac083126ea
0xa3d70a3d70a3d70a3d70a3d70a3d70a4 0xcccccccccccccccccccccccccccccccd
0x80000000000000000000000000000000 0xa0000000000000000000000000000000
0xc8000000000000000000000000000000 0xfa000000000000000000000000000000
0x9c400000000000000000000000000000 0xc3500000000000000000000000000000
0xf4240000000000000000000000000000 0x98968000000000000000000000000000
0xbebc2000000000000000000000000000 0xee6b2800000000000000000000000000
0x9502f900000000000000000000000000 0xba43b740000000000000000000000000
0xe8d4a510000000000000000000000000 0x9184e72a000000000000000000000000
0xb5e620f4800000000000000000000000 0xe35fa931a00000000000000000000000
0x8e1bc9bf040000000000000000000000 0xb1a2bc2ec50000000000000000000000
0xde0b6b3a764000000000000000000000 0x8ac7230489e800000000000000000000
0xad78ebc5ac6200000000000000000000 0xd8d726b7177a80000000000000000000
0x878678326eac90000000000000000000 0xa968163f0a57b4000000000000000000
0xd3c21bcecceda1000000000000000000 0x84595161401484a00000000000000000
0xa56fa5b99019a5c80000000000000000 0xcecb8f27f4200f3a0000000000000000
0x813f3978f89409844000000000000000 0xa18f07d736b90be55000000000000000
0xc9f2c9cd04674edea400000000000000 0xfc6f7c40458122964d00000000000000
0x9dc5ada82b70b59df020000000000000 0xc5371912364ce3056c28000000000000
0xf684df56c3e01bc6c732000000000000 0x9a130b963a6c115c3c7f400000000000
0xc097ce7bc90715b34b9f100000000000 0xf0bdc21abb48db201e86d40000000000
0x96769950b50d88f41314448000000000 0xbc143fa4e250eb3117d955a000000000
0xeb194f8e1ae525fd5dcfab0800000000 0x92efd1b8d0cf37be5aa1cae500000000
0xb7abc627050305adf14a3d9e40000000 0xe596b7b0c643c7196d9ccd05d0000000
0x8f7e32ce7bea5c6fe4820023a2000000 0xb35dbf821ae4f38bdda2802c8a800000
0xe0352f62a19e306ed50b2037ad200000 0x8c213d9da502de454526f422cc340000
0xaf298d050e4395d69670b12b7f410000 0xdaf3f04651d47b4c3c0cdd765f114000
0x88d8762bf324cd0fa5880a69fb6ac800 0xab0e93b6efee00538eea0d047a457a00
0xd5d238a4abe9806872a4904598d6d880 0x85a36366eb71f04147a6da2b7f864750
0xa70c3c40a64e6c51999090b65f67d924 0xd0cf4b50cfe20765fff4b4e3f741cf6d
0x82818f1281ed449fbff8f10e7a8921a5 0xa321f2d7226895c7aff72d52192b6a0e
0xcbea6f8ceb02bb399bf4f8a69f764491 0xfee50b7025c36a0802f236d04753d5b5
0x9f4f2726179a224501d762422c946591 0xc722f0ef9d80aad6424d3ad2b7b97ef6
0xf8ebad2b84e0d58bd2e0898765a7deb3 0x9b934c3b330c857763cc55f49f88eb30
0xc2781f49ffcfa6d53cbf6b71c76b25fc 0xf316271c7fc3908a8bef464e3945ef7b
0x97edd871cfda3a5697758bf0e3cbb5ad 0xbde94e8e43d0c8ec3d52eeed1cbea318
0xed63a231d4c4fb274ca7aaa863ee4bde 0x945e455f24fb1cf88fe8caa93e74ef6b
0xb975d6b6ee39e436b3e2fd538e122b45 0xe7d34c64a9c85d4460dbbca87196b617
0x90e40fbeea1d3a4abc8955e946fe31ce 0xb51d13aea4a488dd6babab6398bdbe42
0xe264589a4dcdab14c696963c7eed2dd2 0x8d7eb76070a08aecfc1e1de5cf543ca3
0xb0de65388cc8ada83b25a55f43294bcc 0xdd15fe86affad91249ef0eb713f39ebf
0x8a2dbf142dfcc7ab6e3569326c784338 0xacb92ed9397bf99649c2c37f07965405
0xd7e77a8f87daf7fbdc33745ec97be907 0x86f0ac99b4e8dafd69a028bb3ded71a4
0xa8acd7c0222311bcc40832ea0d68ce0d 0xd2d80db02aabd62bf50a3fa490c30191
0x83c7088e1aab65db792667c6da79e0fb 0xa4b8cab1a1563f52577001b891185939
0xcde6fd5e09abcf26ed4c0226b55e6f87 0x80b05e5ac60b6178544f8158315b05b5
0xa0dc75f1778e39d6696361ae3db1c722 0xc913936dd571c84c03bc3a19cd1e38ea
0xfb5878494ace3a5f04ab48a04065c724 0x9d174b2dcec0e47b62eb0d64283f9c77
0xc45d1df942711d9a3ba5d0bd324f8395 0xf5746577930d6500ca8f44ec7ee3647a
0x9968bf6abbe85f207e998b13cf4e1ecc 0xbfc2ef456ae276e89e3fedd8c321a67f
0xefb3ab16c59b14a2c5cfe94ef3ea101f 0x95d04aee3b80ece5bba1f1d158724a13
0xbb445da9ca61281f2a8a6e45ae8edc98 0xea1575143cf97226f52d09d71a3293be
0x924d692ca61be758593c2626705f9c57 0xb6e0c377cfa2e12e6f8b2fb00c77836d
0xe498f455c38b997a0b6dfb9c0f956448 0x8edf98b59a373fec4724bd4189bd5ead
0xb2977ee300c50fe758edec91ec2cb658 0xdf3d5e9bc0f653e12f2967b66737e3ee
0x8b865b215899f46cbd79e0d20082ee75 0xae67f1e9aec07187ecd8590680a3aa12
0xda01ee641a708de9e80e6f4820cc9496 0x884134fe908658b23109058d147fdcde
0xaa51823e34a7eedebd4b46f0599fd416 0xd4e5e2cdc1d1ea966c9e18ac7007c91b
0x850fadc09923329e03e2cf6bc604ddb1 0xa6539930bf6bff4584db8346b786151d
0xcfe87f7cef46ff16e612641865679a64 0x81f14fae158c5f6e4fcb7e8f3f60c07f
0xa26da3999aef7749e3be5e330f38f09e 0xcb090c8001ab551c5cadf5bfd3072cc6
0xfdcb4fa002162a6373d9732fc7c8f7f7 0x9e9f11c4014dda7e2867e7fddcdd9afb
0xc646d63501a1511db281e1fd541501b9 0xf7d88bc24209a5651f225a7ca91a4227
0x9ae757596946075f3375788de9b06959 0xc1a12d2fc39789370052d6b1641c83af
0xf209787bb47d6b84c0678c5dbd23a49b 0x9745eb4d50ce6332f840b7ba963646e1
0xbd176620a501fbffb650e5a93bc3d899 0xec5d3fa8ce427affa3e51f138ab4cebf
0x93ba47c980e98cdfc66f336c36b10138 0xb8a8d9bbe123f017b80b0047445d4185
0xe6d3102ad96cec1da60dc059157491e6 0x9043ea1ac7e4139287c89837ad68db30
0xb454e4a179dd187729babe4598c311fc 0xe16a1dc9d8545e94f4296dd6fef3d67b
0x8ce2529e2734bb1d1899e4a65f58660d 0xb01ae745b101e9e45ec05dcff72e7f90
0xdc21a1171d42645d76707543f4fa1f74 0x899504ae72497eba6a06494a791c53a9
0xabfa45da0edbde690487db9d17636893 0xd6f8d7509292d60345a9d2845d3c42b7
0x865b86925b9bc5c20b8a2392ba45a9b3 0xa7f26836f282b7328e6cac7768d7141f
0xd1ef0244af2364ff3207d795430cd927 0x8335616aed761f1f7f44e6bd49e807b9
0xa402b9c5a8d3a6e75f16206c9c6209a7 0xcd036837130890a136dba887c37a8c10
0x802221226be55a64c2494954da2c978a 0xa02aa96b06deb0fdf2db9baa10b7bd6d
0xc83553c5c8965d3d6f92829494e5acc8 0xfa42a8b73abbf48ccb772339ba1f17fa
0x9c69a97284b578d7ff2a760414536efc 0xc38413cf25e2d70dfef5138519684abb
0xf46518c2ef5b8cd17eb258665fc25d6a 0x98bf2f79d5993802ef2f773ffbd97a62
0xbeeefb584aff8603aafb550ffacfd8fb 0xeeaaba2e5dbf678495ba2a53f983cf39
0x952ab45cfa97a0b2dd945a747bf26184 0xba756174393d88df94f971119aeef9e5
0xe912b9d1478ceb177a37cd5601aab85e 0x91abb422ccb812eeac62e055c10ab33b
0xb616a12b7fe617aa577b986b314d600a 0xe39c49765fdf9d94ed5a7e85fda0b80c
0x8e41ade9fbebc27d14588f13be847308 0xb1d219647ae6b31c596eb2d8ae258fc9
0xde469fbd99a05fe36fca5f8ed9aef3bc 0x8aec23d680043bee25de7bb9480d5855
0xada72ccc20054ae9af561aa79a10ae6b 0xd910f7ff28069da41b2ba1518094da05
0x87aa9aff7904228690fb44d2f05d0843 0xa99541bf57452b28353a1607ac744a54
0xd3fa922f2d1675f242889b8997915ce9 0x847c9b5d7c2e09b769956135febada12
0xa59bc234db398c2543fab9837e699096 0xcf02b2c21207ef2e94f967e45e03f4bc
0x8161afb94b44f57d1d1be0eebac278f6 0xa1ba1ba79e1632dc6462d92a69731733
0xca28a291859bbf937d7b8f7503cfdcff 0xfcb2cb35e702af785cda735244c3d43f
0x9defbf01b061adab3a0888136afa64a8 0xc56baec21c7a1916088aaa1845b8fdd1
0xf6c69a72a3989f5b8aad549e57273d46 0x9a3c2087a63f639936ac54e2f678864c
0xc0cb28a98fcf3c7f84576a1bb416a7de 0xf0fdf2d3f3c30b9f656d44a2a11c51d6
0x969eb7c47859e7439f644ae5a4b1b326 0xbc4665b596706114873d5d9f0dde1fef
0xeb57ff22fc0c7959a90cb506d155a7eb 0x9316ff75dd87cbd809a7f12442d588f3
0xb7dcbf5354e9bece0c11ed6d538aeb30 0xe5d3ef282a242e818f1668c8a86da5fb
0x8fa475791a569d10f96e017d694487bd 0xb38d92d760ec445537c981dcc395a9ad
0xe070f78d3927556a85bbe253f47b1418 0x8c469ab843b8956293956d7478ccec8f
0xaf58416654a6babb387ac8d1970027b3 0xdb2e51bfe9d0696a06997b05fcc0319f
0x88fcf317f22241e2441fece3bdf81f04 0xab3c2fddeeaad25ad527e81cad7626c4
0xd60b3bd56a5586f18a71e223d8d3b075 0x85c7056562757456f6872d5667844e4a
0xa738c6bebb12d16cb428f8ac016561dc 0xd106f86e69d785c7e13336d701beba53
0x82a45b450226b39cecc0024661173474 0xa34d721642b0608427f002d7f95d0191
0xcc20ce9bd35c78a531ec038df7b441f5 0xff290242c83396ce7e67047175a15272
0x9f79a169bd203e410f0062c6e984d387 0xc75809c42c684dd152c07b78a3e60869
0xf92e0c3537826145a7709a56ccdf8a83 0x9bbcc7a142b17ccb88a66076400bb692
0xc2abf989935ddbfe6acff893d00ea436 0xf356f7ebf83552fe0583f6b8c4124d44
0x98165af37b2153dec3727a337a8b704b 0xbe1bf1b059e9a8d6744f18c0592e4c5d
0xeda2ee1c7064130c1162def06f79df74 0x9485d4d1c63e8be78addcb5645ac2ba9
0xb9a74a0637ce2ee16d953e2bd7173693 0xe8111c87c5c1ba99c8fa8db6ccdd0438
0x910ab1d4db9914a01d9c9892400a22a3 0xb54d5e4a127f59c82503beb6d00cab4c
0xe2a0b5dc971f303a2e44ae64840fd61e 0x8da471a9de737e245ceaecfed289e5d3
0xb10d8e1456105dad7425a83e872c5f48 0xdd50f1996b947518d12f124e28f7771a
0x8a5296ffe33cc92f82bd6b70d99aaa70 0xace73cbfdc0bfb7b636cc64d1001550c
0xd8210befd30efa5a3c47f7e05401aa4f 0x8714a775e3e95c7865acfaec34810a72
0xa8d9d1535ce3b3967f1839a741a14d0e 0xd31045a8341ca07c1ede48111209a051
0x83ea2b892091e44d934aed0aab460433 0xa4e4b66b68b65d60f81da84d56178540
0xce1de40642e3f4b936251260ab9d668f 0x80d2ae83e9ce78f3c1d72b7c6b42601a
0xa1075a24e4421730b24cf65b8612f820 0xc94930ae1d529cfcdee033f26797b628
0xfb9b7cd9a4a7443c169840ef017da3b2 0x9d412e0806e88aa58e1f289560ee864f
0xc491798a08a2ad4ef1a6f2bab92a27e3 0xf5b5d7ec8acb58a2ae10af696774b1dc
0x9991a6f3d6bf1765acca6da1e0a8ef2a 0xbff610b0cc6edd3f17fd090a58d32af4
0xeff394dcff8a948eddfc4b4cef07f5b1 0x95f83d0a1fb69cd94abdaf101564f98f
0xbb764c4ca7a4440f9d6d1ad41abe37f2 0xea53df5fd18d551384c86189216dc5ee
0x92746b9be2f8552c32fd3cf5b4e49bb5 0xb7118682dbb66a773fbc8c33221dc2a2
0xe4d5e82392a405150fabaf3feaa5334b 0x8f05b1163ba6832d29cb4d87f2a7400f
0xb2c71d5bca9023f8743e20e9ef511013 0xdf78e4b2bd342cf6914da9246b255417
0x8bab8eefb6409c1a1ad089b6c2f7548f 0xae9672aba3d0c320a184ac2473b529b2
0xda3c0f568cc4f3e8c9e5d72d90a2741f 0x8865899617fb18717e2fa67c7a658893
0xaa7eebfb9df9de8dddbb901b98feeab8 0xd51ea6fa85785631552a74227f3ea566
0x8533285c936b35ded53a88958f872760 0xa67ff273b84603568a892abaf368f138
0xd01fef10a657842c2d2b7569b0432d86 0x8213f56a67f6b29b9c3b29620e29fc74
0xa298f2c501f45f428349f3ba91b47b90 0xcb3f2f7642717713241c70a936219a74
0xfe0efb53d30dd4d7ed238cd383aa0111 0x9ec95d1463e8a506f4363804324a40ab
0xc67bb4597ce2ce48b143c6053edcd0d6 0xf81aa16fdc1b81dadd94b7868e94050b
0x9b10a4e5e9913128ca7cf2b4191c8327 0xc1d4ce1f63f57d72fd1c2f611f63a3f1
0xf24a01a73cf2dccfbc633b39673c8ced 0x976e41088617ca01d5be0503e085d814
0xbd49d14aa79dbc824b2d8644d8a74e19 0xec9c459d51852ba2ddf8e7d60ed1219f
0x93e1ab8252f33b45cabb90e5c942b504 0xb8da1662e7b00a173d6a751f3b936244
0xe7109bfba19c0c9d0cc512670a783ad5 0x906a617d450187e227fb2b80668b24c6
0xb484f9dc9641e9dab1f9f660802dedf7 0xe1a63853bbd264515e7873f8a0396974
0x8d07e33455637eb2db0b487b6423e1e9 0xb049dc016abc5e5f91ce1a9a3d2cda63
0xdc5c5301c56b75f77641a140cc7810fc 0x89b9b3e11b6329baa9e904c87fcb0a9e
0xac2820d9623bf429546345fa9fbdcd45 0xd732290fbacaf133a97c177947ad4096
0x867f59a9d4bed6c049ed8eabcccc485e 0xa81f301449ee8c705c68f256bfff5a75
0xd226fc195c6a2f8c73832eec6fff3112 0x83585d8fd9c25db7c831fd53c5ff7eac
0xa42e74f3d032f525ba3e7ca8b77f5e56 0xcd3a1230c43fb26f28ce1bd2e55f35ec
0x80444b5e7aa7cf857980d163cf5b81b4 0xa0555e361951c366d7e105bcc3326220
0xc86ab5c39fa634408dd9472bf3fefaa8 0xfa856334878fc150b14f98f6f0feb952
0x9c935e00d4b9d8d26ed1bf9a569f33d4 0xc3b8358109e84f070a862f80ec4700c9
0xf4a642e14c6262c8cd27bb612758c0fb 0x98e7e9cccfbd7dbd8038d51cb897789d
0xbf21e44003acdd2ce0470a63e6bd56c4 0xeeea5d50049814781858ccfce06cac75
0x95527a5202df0ccb0f37801e0c43ebc9 0xbaa718e68396cffdd30560258f54e6bb
0xe950df20247c83fd47c6b82ef32a206a 0x91d28b7416cdd27e4cdc331d57fa5442
0xb6472e511c81471de0133fe4adf8e953 0xe3d8f9e563a198e558180fddd97723a7
0x8e679c2f5e44ff8f570f09eaa7ea7649 0xb201833b35d63f732cd2cc6551e513db
0xde81e40a034bcf4ff8077f7ea65e58d2 0x8b112e86420f6191fb04afaf27faf783
0xadd57a27d29339f679c5db9af1f9b564 0xd94ad8b1c738087418375281ae7822bd
0x87cec76f1c8305488f2293910d0b15b6 0xa9c2794ae3a3c69ab2eb3875504ddb23
0xd433179d9c8cb8415fa60692a46151ec 0x849feec281d7f328dbc7c41ba6bcd334
0xa5c7ea73224deff312b9b522906c0801 0xcf39e50feae16befd768226b34870a01
0x81842f29f2cce375e6a1158300d46641 0xa1e53af46f801c5360495ae3c1097fd1
0xca5e89b18b602368385bb19cb14bdfc5 0xfcf62c1dee382c4246729e03dd9ed7b6
0x9e19db92b4e31ba96c07a2c26a8346d2 0xc5a05277621be293c7098b7305241886
0xf70867153aa2db38b8cbee4fc66d1ea8
}

: φ ( k -- φ ) 290 + lookup-table nth ; inline

: β ( E k -- β ) ⌊nlog2_10⌋ + ; inline

:: wi ( F φ β n parity? -- wi wi? )
    F 2 * n + φ * β 128 -
    [ shift parity? [ odd? ] when ]
    [ neg 2^ 1 - bitand zero? ] 2bi ; inline

: xi ( F φ β -- xi-odd? xi? ) -1 t wi ; inline
: yi ( F φ β -- yi-odd? yi? )  0 t wi ; inline
: zi ( F φ β -- zi      zi? )  1 f wi ; inline

: s/r ( zi -- s r ) [ 1000/ ] keep over 1000 * - ; inline

: δi ( φ β -- δi ) 127 - shift ; inline

: strip-zeroes ( s -- s' d )
    0 [
        over 10 /mod zero?
        [ [ nipd swap 1 + ] [ drop ] if ] keep
    ] loop ; inline

:: normal-interval ( F E -- f e )
    F even? :> w∈I?
    E k :> k
    k φ :> φ
    E k β :> β
    φ β δi :> δi
    F φ β zi :> ( zi zi? )
    zi s/r
    dup δi 2dup > [ 2drop f ] [
        number= [
            F φ β xi :> ( xi-odd? xi? )
            xi-odd? [ w∈I? not xi? or ] unless*
        ] [
            w∈I? not over zero? zi? and and
            [ [ [ 1 - ] [ drop 1000 ] bi* ] when ] keep not
        ] if
    ] if [
        drop strip-zeroes k - 3 +
    ] [
        50 + δi 2/ - :> D
        D 100/mod :> ( t ρ≠0? )
        10 * t + ρ≠0? [
            F φ β yi :> ( yi-odd? yi? )
            D 50 - even? yi-odd? eq? over odd? yi? and or [
                1 -
            ] when
        ] unless 2 k -
    ] if ; inline

: k0 ( E -- k0 ) ⌊nlog10_2-log10_4/3⌋ neg ; inline

:: w̃i ( φ β w∈I? E n1 q1 n2 q2 n3 -- w̃i )
    φ -64 2dup 52 - n1 - [ shift ] 2bi@ q1 call β 11 - shift
    w∈I? E n2 3 between? q2 call [ n3 + ] unless ; inline

: x̃i ( φ β x∈I? E -- x̃i ) 2 [ - ] 2 [ and    ]  1 w̃i ; inline
: z̃i ( φ β z∈I? E -- z̃i ) 1 [ + ] 0 [ not or ] -1 w̃i ; inline

: yru ( φ β -- yru ) 74 - shift 1 + 2/ ; inline

:: shorter-interval ( F E -- f e )
    E k0 :> k0
    k0 φ :> φ
    E k0 β :> β
    F even? :> w∈I?
    φ β w∈I? E x̃i :> x̃i
    φ β w∈I? E z̃i :> z̃i
    z̃i 10 /i :> z̃i*
    x̃i z̃i* 10 * <= [ z̃i* strip-zeroes k0 - 1 + ] [
        φ β yru :> yru
        yru E -77 number= [
            yru odd? [ 1 - ] when
        ] [
            yru x̃i >= [ 1 + ] unless
        ] if k0 neg
    ] if ; inline

: dragonbox ( s F E -- s f e )
    [ mantissa-expt-normalize* ] [ shorter-interval? ] 2bi
    [ shorter-interval ] [ normal-interval ] if ; inline

: exponential-format ( sign-str e f-length f-str -- str )
    [ + 1 - ] dip 1 cut [ "." glue ] unless-empty
    "e" append swap >dec 3append ; inline

: decimal-format ( sign-str e f-length f-str -- str )
    2over + neg? [ pick neg CHAR: 0 pad-head ] when
    pick 0 > [ 2over + CHAR: 0 pad-tail ] when
    nip swap neg 0 max cut*
    [ [ "0" ] when-empty ] bi@ "." glue append ; inline

: general-format ( s f e -- str )
    swap >dec [ length ] keep
    2over swap [ + ] [ neg ] bi [ 1 max ] bi@ + 17 >
    [ exponential-format ] [ decimal-format ] if ; inline

: float>dec ( n -- str )
    >double< dragonbox general-format ; inline

: float>base ( n radix -- str )
    {
        { 10 [ float>dec ] }
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
