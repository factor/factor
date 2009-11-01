! (c)2009 Joe Groff bsd license
USING: accessors combinators kernel math
namespaces sequences sequences.private splitting strings make ;
IN: math.parser

: digit> ( ch -- n )
    {
        { [ dup CHAR: 9 <= ] [ CHAR: 0 - ] }
        { [ dup CHAR: a <  ] [ CHAR: A 10 - - ] }
        [ CHAR: a 10 - - ]
    } cond
    dup 0 < [ drop 255 ] when ; inline

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

: (next-digit) ( i number-parse n digit-quot end-quot -- number/f )
    [ 2over length>> < ] 2dip
    [ [ 2over str>> nth-unsafe >fixnum [ 1 + >fixnum ] 3dip ] prepose ] dip if ; inline

: require-next-digit ( i number-parse n quot -- number/f )
    [ 3drop f ] (next-digit) ; inline

: next-digit ( i number-parse n quot -- number/f )
    [ 2nip ] (next-digit) ; inline

: add-digit ( i number-parse n digit quot -- number/f )
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

: add-mantissa-digit ( float-parse i number-parse n digit quot -- float-parse' number/f )
    [ [ inc-point ] 4dip ] dip add-digit ; inline

: make-float-dec-exponent ( float-parse n/f -- float/f )
    [ [ radix>> ] [ point>> ] [ exponent>> ] tri - (pow) ] [ swap /f ] bi* ; inline

: make-float-bin-exponent ( float-parse n/f -- float/f )
    [ drop [ radix>> ] [ point>> ] bi (pow) ]
    [ nip swap /f ]
    [ drop 2.0 swap exponent>> (pow) * ] 2tri ; inline

: ?make-float ( float-parse n/f -- float/f )
    {
        { [ dup not ] [ 2drop f ] }
        { [ over radix>> 10 = ] [ make-float-dec-exponent ] }
        [ make-float-bin-exponent ]
    } cond ; inline

: ?neg ( n/f -- -n/f )
    [ neg ] [ f ] if* ; inline

: ?add-ratio ( m n/f -- m+n/f )
    dup ratio? [ + ] [ 2drop f ] if ; inline

: @abort ( i number-parse n x -- f )
    2drop 2drop f ; inline

: @split ( i number-parse n -- n i number-parse n' )
    -rot 0 ; inline

: @split-exponent ( i number-parse n -- n i number-parse' n' )
    -rot [ str>> ] [ length>> ] bi 10 number-parse boa 0 ; inline

: <float-parse> ( i number-parse n -- float-parse i number-parse n )
     [ drop nip radix>> 0 0 float-parse boa ] 3keep ; inline

DEFER: @exponent-digit
DEFER: @mantissa-digit
DEFER: @denom-digit
DEFER: @num-digit
DEFER: @pos-digit
DEFER: @neg-digit

: @exponent-digit-or-punc ( float-parse i number-parse n char -- float-parse number/f )
    {
        { CHAR: , [ [ @exponent-digit ] require-next-digit ] }
        [ @exponent-digit ]
    } case ; inline recursive

: @exponent-digit ( float-parse i number-parse n char -- float-parse number/f )
    digit-in-radix [ [ @exponent-digit-or-punc ] add-digit ] [ @abort ] if ; inline recursive

: @exponent-first-char ( float-parse i number-parse n char -- float-parse number/f )
    {
        { CHAR: - [ [ @exponent-digit ] require-next-digit ?neg ] }
        [ @exponent-digit ]
    } case ; inline recursive

: ->exponent ( float-parse i number-parse n -- float-parse' number/f )
    @split-exponent [ @exponent-first-char ] require-next-digit ?store-exponent ; inline

: exponent-char? ( number-parse n char -- number-parse n char ? )
    3dup nip swap radix>> {
        { 10 [ [ CHAR: e CHAR: E ] dip [ = ] curry either? ] }
        [ drop [ CHAR: p CHAR: P ] dip [ = ] curry either? ]
    } case ; inline

: or-exponent ( i number-parse n char quot -- number/f )
    ! call ; inline
    [ exponent-char? [ drop <float-parse> ->exponent ?make-float ] ] dip if ; inline
: or-mantissa->exponent ( float-parse i number-parse n char quot -- float-parse number/f )
    ! call ; inline
    [ exponent-char? [ drop ->exponent ] ] dip if ; inline

: @mantissa-digit-or-punc ( float-parse i number-parse n char -- float-parse number/f )
    {
        { CHAR: , [ [ @mantissa-digit ] require-next-digit ] }
        [ @mantissa-digit ]
    } case ; inline recursive

: @mantissa-digit ( float-parse i number-parse n char -- float-parse number/f )
    [
        digit-in-radix
        [ [ @mantissa-digit-or-punc ] add-mantissa-digit ]
        [ @abort ] if
    ] or-mantissa->exponent ; inline recursive

: ->mantissa ( i number-parse n -- number/f )
    <float-parse> [ @mantissa-digit ] next-digit ?make-float ; inline

: ->required-mantissa ( i number-parse n -- number/f )
    <float-parse> [ @mantissa-digit ] require-next-digit ?make-float ; inline

: @denom-digit-or-punc ( i number-parse n char -- number/f )
    {
        { CHAR: , [ [ @denom-digit ] require-next-digit ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @denom-digit ] or-exponent ]
    } case ; inline recursive

: @denom-digit ( i number-parse n char -- number/f )
    digit-in-radix [ [ @denom-digit-or-punc ] add-digit ] [ @abort ] if ; inline recursive

: @denom-first-digit ( i number-parse n char -- number/f )
    {
        { CHAR: . [ ->mantissa ] }
        [ @denom-digit ]
    } case ; inline recursive

: ->denominator ( i number-parse n -- number/f )
    @split [ @denom-first-digit ] require-next-digit ?make-ratio ; inline

: @num-digit-or-punc ( i number-parse n char -- number/f )
    {
        { CHAR: , [ [ @num-digit ] require-next-digit ] }
        { CHAR: / [ ->denominator ] }
        [ @num-digit ]
    } case ; inline recursive

: @num-digit ( i number-parse n char -- number/f )
    digit-in-radix [ [ @num-digit-or-punc ] add-digit ] [ @abort ] if ; inline recursive

: ->numerator ( i number-parse n -- number/f )
    @split [ @num-digit ] require-next-digit ?add-ratio ; inline

: @pos-digit-or-punc ( i number-parse n char -- number/f )
    {
        { CHAR: , [ [ @pos-digit ] require-next-digit ] }
        { CHAR: + [ ->numerator ] }
        { CHAR: / [ ->denominator ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @pos-digit ] or-exponent ]
    } case ; inline recursive

: @pos-digit ( i number-parse n char -- number/f )
    digit-in-radix [ [ @pos-digit-or-punc ] add-digit ] [ @abort ] if ; inline recursive

: @pos-first-digit ( i number-parse n char -- number/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        [ @pos-digit ]
    } case ; inline recursive

: @neg-digit-or-punc ( i number-parse n char -- number/f )
    {
        { CHAR: , [ [ @neg-digit ] require-next-digit ] }
        { CHAR: - [ ->numerator ] }
        { CHAR: / [ ->denominator ] }
        { CHAR: . [ ->mantissa ] }
        [ [ @neg-digit ] or-exponent ]
    } case ; inline recursive

: @neg-digit ( i number-parse n char -- number/f )
    digit-in-radix [ [ @neg-digit-or-punc ] add-digit ] [ @abort ] if ; inline recursive

: @neg-first-digit ( i number-parse n char -- number/f )
    {
        { CHAR: . [ ->required-mantissa ] }
        [ @neg-digit ]
    } case ; inline recursive

: @first-char ( i number-parse n char -- number/f ) 
    {
        { CHAR: - [ [ @neg-first-digit ] require-next-digit ?neg ] }
        [ @pos-first-digit ]
    } case ; inline recursive

PRIVATE>

: base> ( str radix -- number/f )
    <number-parse> [ @first-char ] require-next-digit ;

: string>number ( str -- number/f ) 10 base> ; inline

: bin> ( str -- number/f )  2 base> ; inline
: oct> ( str -- number/f )  8 base> ; inline
: dec> ( str -- number/f ) 10 base> ; inline
: hex> ( str -- number/f ) 16 base> ; inline

: string>digits ( str -- digits )
    [ digit> ] B{ } map-as ; inline

: (digits>integer) ( valid? accum digit radix -- valid? accum )
    2dup < [ swapd * + ] [ 2drop 2drop f 0 ] if ; inline

: each-digit ( seq radix quot -- n/f )
    [ t 0 ] 3dip curry each swap [ drop f ] unless ; inline

: digits>integer ( seq radix -- n/f )
    [ (digits>integer) ] each-digit ; inline

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ; inline

: positive>base ( num radix -- str )
    dup 1 <= [ "Invalid radix" throw ] when
    [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
    reverse! ; inline

GENERIC# >base 1 ( n radix -- str )

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
    dup zero?
    [ over log2 52 swap - [ shift 52 2^ 1 - bitand ] [ 1022 + - ] bi-curry bi* ]
    [ 1023 - ] if ;

: mantissa-expt ( float -- mantissa expt )
    [ 52 2^ 1 - bitand ]
    [ -0.0 double>bits bitnot bitand -52 shift ] bi
    mantissa-expt-normalize ;

: float>hex-sign ( bits -- str )
    -0.0 double>bits bitand zero? "" "-" ? ;

: float>hex-value ( mantissa -- str )
    16 >base 13 CHAR: 0 pad-head [ CHAR: 0 = ] trim-tail
    [ "0" ] [ ] if-empty "1." prepend ;

: float>hex-expt ( mantissa -- str )
    10 >base "p" prepend ;

: float>hex ( n -- str )
    double>bits
    [ float>hex-sign ] [
        mantissa-expt [ float>hex-value ] [ float>hex-expt ] bi*
    ] bi 3append ;

: float>decimal ( n -- str )
    (float>string)
    [ 0 = ] trim-tail >string
    fix-float ;

: float>base ( n base -- str )
    {
        { 16 [ float>hex ] }
        [ drop float>decimal ]
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

: number>string ( n -- str ) 10 >base ; inline
: >bin ( n -- str ) 2 >base ; inline
: >oct ( n -- str ) 8 >base ; inline
: >hex ( n -- str ) 16 >base ; inline

: # ( n -- ) number>string % ; inline

