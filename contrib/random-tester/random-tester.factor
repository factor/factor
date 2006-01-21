USING: kernel math sequences namespaces errors hashtables words arrays parser
       compiler syntax lists io ;
USING: inspector prettyprint ;
USING: optimizer compiler-frontend compiler-backend inference ;
IN: random-tester

! Tweak me
: max-length 5 ; inline
: max-value 1000000000 ; inline


! varying bit-length random number
: random-bits ( n -- int )
    random-int 2 swap ^ random-int ;

: random-seq ( -- seq )
    { [ ] { } V{ } "" } nth-rand
    [ max-length random-int [ max-value random-int , ] times ] swap make ;

SYMBOL: special-integers
[ { -1 0 1 } % most-negative-fixnum , most-positive-fixnum , first-bignum , ] 
{ } make \ special-integers set
: special-integers ( -- seq ) \ special-integers get ;
SYMBOL: special-floats
[ { 0.0 } % e , pi , inf , -inf , 0/0. , epsilon , epsilon neg , ]
{ } make \ special-floats set
: special-floats ( -- seq ) \ special-floats get ;
SYMBOL: special-complexes
[ 
    { -1 0 1 i -i } %
    e , pi , 0 pi rect> , 0 pi neg rect> , pi neg 0 rect> , pi pi rect> ,
    pi pi neg rect> , pi neg pi rect> , pi neg pi neg rect> ,
    e neg e neg rect> , e e rect> ,
] { } make \ special-complexes set

: special-complexes ( -- seq ) \ special-complexes get ;

: random-fixnum ( -- fixnum )
    most-positive-fixnum random-int 1+ coin-flip [ neg 1- ] when >fixnum ;

: random-bignum ( -- bignum )
     400 random-bits first-bignum + coin-flip [ neg ] when ;
    
: random-integer
    coin-flip [
            random-fixnum
        ] [
            coin-flip [ random-bignum ] [ special-integers nth-rand ] if
        ] if ;

: random-positive-integer ( -- int )
    random-integer dup 0 < [
            neg
        ] [
            dup 0 = [ 1 + ] when
    ] if ;

: random-ratio ( -- ratio )
    1000000000 dup [ random-int ] 2apply 1+ / coin-flip [ neg ] when dup [ drop random-ratio ] unless ;

: random-float ( -- float )
    coin-flip [ random-ratio ] [ special-floats nth-rand ] if
    coin-flip 
    [ .0000000000000000001 /f ] [ coin-flip [ .00000000000000001 * ] when ] if
    >float ;

: random-number ( -- number )
    {
        [ random-integer ]
        [ random-ratio ]
        [ random-float ]
    } do-one ;

: random-complex ( -- C{ } )
    random-number random-number rect> ;


! Math vocabulary words
: math-1 ( -- seq )
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        bitnot bits>double bits>float ceiling cis conjugate cos cosec cosech
        cosh cot coth denominator double>bits exp float>bits floor imaginary
        log neg next-power-of-2 numerator quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;
! TODO: take this out eventually
: math-throw-1
    {
        recip
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;

: integer>x
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        bitnot bits>double bits>float ceiling cis conjugate cos cosec cosech
        cosh cot coth denominator double>bits exp float>bits floor imaginary
        log neg next-power-of-2 numerator quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;

: ratio>x
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        cis conjugate cos cosec cosech
        cosh cot coth double>bits exp float>bits floor imaginary
        log neg next-power-of-2 quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;

! ceiling, truncate, floor eventually
: float>x ( float -- x )
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        cis conjugate cos cosec cosech
        cosh cot coth double>bits exp float>bits imaginary
        log neg next-power-of-2 quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh 
    } ;

: complex>x
    {
        1+ 1- abs absq arg 
        conjugate cos cosec cosech
        cosh cot coth exp imaginary
        log neg quadrant real sec
        sech sin sinh sq sqrt tan tanh 
    } ;

: integer>integer
    {
        1+ 1- >bignum >digit >fixnum abs absq 
        bitnot ceiling conjugate 
        denominator double>bits float>bits floor imaginary
        neg next-power-of-2 numerator quadrant
        real sgn sq truncate 
    } ;

: ratio>ratio
    {
        1+ 1- >digit abs absq conjugate neg real sq
    } ;

: float>float
    {
        1+ 1- >digit abs absq arg 
        conjugate cos cosec cosech
        cosh cot coth exp neg real sec
        sech sin sinh sq tan tanh 
    } ;

: complex>complex
    {
        1+ 1- abs absq arg 
        conjugate cosec cosech
        cosh cot coth exp 
        log neg quadrant 
        sech sin sinh sq sqrt tanh 
    } ;




: math-2 ( -- seq )
    { * + - /f max min polar> bitand bitor bitxor align shift } ;
: math-throw-2 ( -- seq ) { / /i ^ mod rem } ;

! shift too but can't test with bignums..
: 2integer>x ( n n -- x ) ( -- word )
    { * + - /f max min polar> bitand bitor bitxor align } ;
: 2ratio>x ( r r -- x ) ( -- word ) { * + - /f max min polar> } ;
: 2float>x ( f f -- x ) ( -- word ) { * + - /f max min polar> } ;
: 2complex>x ( c c -- x ) ( -- word ) { * + - /f } ;

: 2integer>integer ( n n -- n ) ( -- word )
    { * + - /f max min polar> bitand bitor bitxor align } ;
: 2ratio>ratio ( r r -- r ) ( -- word ) { * + - /f max min } ;
: 2float>float ( f f -- f ) ( -- word ) { * + - /f max min polar> } ;
: 2complex>complex ( c c -- c ) ( -- word ) { * + - /f } ;




: random-integer-quotation ( -- quot )
    [
        random-integer ,
        max-length random-int
        [
            [
                [ integer>integer nth-rand , ]
                [ random-integer , 2integer>integer nth-rand , ]
            ] do-one
        ] times
    ] [ ] make ;

: random-ratio-quotation ( -- quot )
    [
        random-ratio ,
        max-length random-int
        [
            [
                [ ratio>ratio nth-rand , ]
                [ random-ratio , 2ratio>ratio nth-rand , ]
            ] do-one
        ] times
    ] [ ] make ;

: random-float-quotation ( -- quot )
    [
        random-float ,
        max-length random-int
        [
            [
                [ float>float nth-rand , ]
                [ random-float , 2float>float nth-rand , ]
            ] do-one
        ] times
    ] [ ] make ;

: random-complex-quotation ( -- quot )
    [
        random-complex ,
        max-length random-int
        [
            [
                [ complex>complex nth-rand , ]
                [ random-complex , 2complex>complex nth-rand , ]
            ] do-one
        ] times
    ] [ ] make ;


: interp-compile-check ( quot -- )
    dup . [ call ] keep compile-1
    2dup swap unparse write " " write unparse print
    = [ "problem in math" throw ] unless ;

! 1-arg tests
: test-integer>x ( -- )
    random-integer integer>x nth-rand f cons cons interp-compile-check ;

: test-ratio>x ( -- )
    random-ratio ratio>x nth-rand f cons cons interp-compile-check ;

: test-float>x ( -- )
    random-float float>x nth-rand f cons cons interp-compile-check ;

: test-complex>x ( -- )
    random-complex complex>x nth-rand f cons cons interp-compile-check ;


! 2-arg tests
: test-2integer>x ( -- )
    random-integer random-integer 2integer>x nth-rand f cons cons cons interp-compile-check ;

: test-2ratio>x ( -- )
    random-ratio random-ratio 2ratio>x nth-rand f cons cons cons interp-compile-check ;

: test-2float>x ( -- )
    random-float random-float 2float>x nth-rand f cons cons cons interp-compile-check ;

: test-2complex>x ( -- )
    random-complex random-complex 2complex>x nth-rand f cons cons cons interp-compile-check ;


: test-2random>x ( -- )
    random-number random-number math-2 nth-rand f cons cons cons interp-compile-check ;


! quotation tests
: test-integer random-integer-quotation interp-compile-check ;
: test-ratio random-ratio-quotation interp-compile-check ;
: test-float random-float-quotation interp-compile-check ;
: test-complex random-complex-quotation interp-compile-check ;

: test-math {
        [ test-integer ]
        [ test-ratio ]
        [ test-float ]
        [ test-complex ]
    } do-one ;

: if-quot ( -- )
    max-length [
    ] times ;


! : test-if
    ! nested-if-quot compile-check-output ;


: stack-identity-0
    H{
        { 1 drop }
        { 1000000000000000000000000001 drop }
        { -11111111111111111111111111 drop }
        { -1 drop }
        { 1.203 drop }
        { -1.203 drop }
        { "asdf" drop }
     } ; inline
: stack-identity-1
    H{
        { dup drop }
        { >r r> }
     } ; inline
: stack-identity-2
    H{
        { swap swap }
        { over drop }
        { dupd nip }
        { 2dup 2drop }
     } ; inline
: stack-identity-3
    H{
        { rot -rot }
        { pick drop }
        { 3dup 3drop }
     } ; inline
: stack-identity-4
    H{
        { 2swap 2swap }
     } ; inline

: get-stack-identity-table ( n -- hash )
    {
        { [ dup 0 = ] [ drop stack-identity-0 ] }
        { [ dup 1 = ] [ drop stack-identity-1 ] }
        { [ dup 2 = ] [ drop stack-identity-2 ] }
        { [ dup 3 = ] [ drop stack-identity-3 ] }
        { [ dup 4 = ] [ drop stack-identity-4 ] }
        { [ t ] [ drop f ] }
    } cond ;

: get-stack-identity-table<= ( n -- hash )
    1+ random-int get-stack-identity-table ;


: random-stack-identity ( n -- quot )
    #! n is number of items on stack
    [
        max-length random-int
        [ dup get-stack-identity-table<= random-hash-entry swap , , ] times
        drop
    ] [ ] make ;


: stack-identity ; ! dummy

: define-random-stack-identity ( n -- )
    random-stack-identity \ stack-identity dup reset-generic swap
    define-compound \ stack-identity compile ;

: test-random-stack-identity ( -- )
    4 define-random-stack-identity
    1 2 3 4 stack-identity 4array { 1 2 3 4 } =
    [ \ stack-identity see "bad stack-identity!" throw ] unless ;

: (test-random-seq-iterate) ( seq -- )
    [ [ 2 3 4 stack-identity 3drop ] keep = [ "not equal" throw ] unless ] each ;

: test-random-seq-iterate ( -- )
    4 define-random-stack-identity
        ! \ stack-identity see
    random-seq
        ! dup .
    (test-random-seq-iterate) ;


: random-test
    { test-random-stack-identity test-random-seq-iterate test-math }
    nth-rand execute ;

: random-test-loop ( n -- )
    [ random-test ] times ;

: watch-simplifier
    [
        dup word-def dataflow optimize
        linearize [ split-blocks simplify . ] hash-each
    ] with-compiler ;


