USING: kernel math sequences namespaces errors hashtables words arrays parser
       compiler syntax lists io ;
USING: inspector prettyprint ;
USING: optimizer compiler-frontend compiler-backend inference ;
IN: random-tester

! Math words are listed in arrays according to the number of arguments,
! if they can throw exceptions or not, and what they output.
! integer>x -> takes an integer, outputs anything
! integer>integer -> always outputs an integer

! Math vocabulary words
: math-1 ( -- seq )
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        bitnot bits>double bits>float ceiling cis conjugate cos cosec cosech
        cosh cot coth denominator double>bits exp float>bits floor imaginary
        log neg next-power-of-2 numerator quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;
: math-throw-1
    {
        recip log2
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
        ceiling cis conjugate cos cosec cosech
        cosh cot coth double>bits exp float>bits floor imaginary
        log neg next-power-of-2 quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate
    } ;

: complex>x
    {
        1+ 1- abs absq arg 
        conjugate cos cosec cosech
        cosh cot coth exp imaginary
        log neg quadrant real
        sec sech sin sinh sq sqrt tan tanh 
    } ;

: integer>x-throw
    {
        recip log2
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;
: ratio>x-throw
    {
        recip
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;

: integer>integer
    {
        1+ 1- >bignum >digit >fixnum abs absq 
        bitnot ceiling conjugate 
        denominator double>bits float>bits floor imaginary
        neg next-power-of-2 numerator quadrant
        real sgn sq truncate 
    } ;

: ratio>ratio { 1+ 1- >digit abs absq conjugate neg real sq } ;

: float>float
    {
        1+ 1- >digit abs absq arg ceiling
        conjugate cos cosec cosech
        cosh cot coth exp floor neg real sec
        sech sin sinh sq tan tanh truncate
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
    { * + - /f max min polar> bitand bitor bitxor align } ;
: math-throw-2 ( -- seq ) { / /i mod rem } ;

: 2integer>x ( n n -- x ) ( -- word )
    { * + - /f max min polar> bitand bitor bitxor align } ;
: 2ratio>x ( r r -- x ) ( -- word ) { * + - /f max min polar> } ;
: 2float>x ( f f -- x ) ( -- word ) { * + - /f max min polar> } ;
: 2complex>x ( c c -- x ) ( -- word ) { * + - /f } ;

: 2integer>integer ( n n -- n ) ( -- word )
    { * + - max min bitand bitor bitxor align } ;
: 2ratio>ratio ( r r -- r ) ( -- word ) { * + - max min } ;
: 2float>float ( f f -- f ) ( -- word ) { * + - /f max min } ;
: 2complex>complex ( c c -- c ) ( -- word ) { * + - /f } ;

: (random-integer-quotation) ( -- quot )
    random-integer ,
    max-length random-int
    [
        [
            [ integer>integer nth-rand , ]
            [ random-integer , 2integer>integer nth-rand , ]
        ] do-one
    ] times ;
: random-integer-quotation ( -- quot )
    [
        (random-integer-quotation)
    ] [ ] make ;

: random-integer-quotation-1 ( -- quot )
    [
        (random-integer-quotation) 2integer>integer nth-rand ,
    ] [ ] make ;

: (random-ratio-quotation) ( -- quot )
        random-ratio ,
        max-length random-int
        [
            [
                [ ratio>ratio nth-rand , ]
                [ random-ratio , 2ratio>ratio nth-rand , ]
            ] do-one
        ] times ;

: random-ratio-quotation ( -- quot )
    [
        (random-ratio-quotation)
    ] [ ] make ;

: random-ratio-quotation-1 ( -- quot )
    [
        (random-ratio-quotation) 2ratio>ratio nth-rand ,
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


SYMBOL: last-quot
: interp-compile-check ( quot -- )
    dup . 
    [ last-quot set ] keep
    [ call ] keep compile-1
    2dup swap unparse write " " write unparse print
    = [ "problem in math" throw ] unless ;

: interp-compile-check-1 ( x quot -- )
    dup . flush
    [ last-quot set ] keep
    [ call ] 2keep compile-1
    2dup swap unparse write " " write unparse print
    = [ "problem in math" throw ] unless ;

: interp-compile-check* ( quot -- )
    dup .
    >r 100 200 300 400 r> [ call 4array ] keep
    >r 100 200 300 400 r> compile-1 4array
    = [ "problem found! (compile-check*)" throw ] unless ;

: interp-compile-check-catch ( quot -- )
    dup .
    [ last-quot set ] keep
    [ catch [ "caught: " write dup print-error ] when* ] keep 
    [ compile-1 ] catch [ nip "caught: " write dup print-error ] when*
    = [ "problem in math" throw ] unless ;

: update-math-xt ( -- )
    math-1 [ update-xt ] each
    math-throw-1 [ update-xt ] each
    math-2 [ update-xt ] each
    math-throw-2 [ update-xt ] each ;

: update-xt-check ( quot -- )
    update-math-xt
    dup .
    [ last-quot set ] keep
    [ call ] keep
    [ last car update-xt ] keep call
    2dup swap unparse write " " write unparse print
    = [ "update-xt problem" throw ] unless ;




! 1-arg tests
    
: random-integer>x-quot random-integer integer>x nth-rand unit cons ;
: random-ratio>x-quot ( -- ) random-ratio ratio>x nth-rand unit cons ;
: random-float>x-quot ( -- ) random-float float>x nth-rand unit cons ;
: random-complex>x-quot ( -- ) random-complex complex>x nth-rand unit cons ;

: test-integer>x ( -- ) random-integer>x-quot interp-compile-check ;
: test-ratio>x ( -- ) random-ratio>x-quot interp-compile-check ;
: test-float>x ( -- ) random-float>x-quot interp-compile-check ;
: test-complex>x ( -- ) random-complex>x-quot interp-compile-check ;


: test-integer>x-1 ( -- )
    random-integer integer>x nth-rand unit interp-compile-check-1 ;
: test-ratio>x-1 ( -- )
    random-ratio ratio>x nth-rand unit interp-compile-check-1 ;
: test-float>x-1 ( -- )
    random-float float>x nth-rand unit interp-compile-check-1 ;
: test-complex>x-1 ( -- )
    random-complex complex>x nth-rand unit interp-compile-check-1 ;

: test-integer>x-throws ( -- )
    random-integer integer>x-throw nth-rand unit cons interp-compile-check-catch ;
: test-ratio>x-throws ( -- )
    random-ratio ratio>x-throw nth-rand unit cons interp-compile-check-catch ;

: test-update-xt ( -- )
    random-integer random-integer 2integer>x nth-rand f cons cons cons update-xt-check ;

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

: test-2integer>x-1 ( -- )
    random-integer random-integer-quotation-1 interp-compile-check-1 ;

: test-2integer>x-throws ( -- )
    [
        random-integer , random-integer ,
        math-throw-2 nth-rand ,
    ] [ ] make interp-compile-check-catch ;

: test-^-shift ( -- )
    [
        100 random-int 50 - ,
        100 random-int 50 - ,
        { ^ shift } nth-rand ,
    ] [ ] make interp-compile-check-catch ;

: test-^-ratio ( -- )
    [
        random-ratio , random-ratio , \ ^ ,
    ] [ ] make interp-compile-check-catch ;

: test-math {
        ! test-integer>x 
        ! test-ratio>x 
        ! test-float>x 
        ! test-complex>x 
        test-integer>x-1
        test-ratio>x-1
        test-float>x-1
        test-complex>x-1
        ! test-integer>x-throws
        ! test-ratio>x-throws

        ! ! test-update-xt
        ! test-2integer>x
        ! test-2ratio>x
        ! test-2float>x
        ! test-2complex>x
        test-2integer>x-1
        ! test-2integer>x-throws
        ! test-^-shift
        ! test-^-ratio
    } nth-rand unit call ;


! Boolean logic tests
: logic-0 ( -- seq )
    { unix? win32? bootstrapping? f t } ;

: logic-1 ( -- seq )
    {
        not tuple? float? integer? complex? ratio? continuation? wrapper?
        number?  rational? bignum? fixnum? float? primitive? symbol?
        compound? real?
    } ;
!  odd? even? power-of-2?
: logic-2 ( -- seq ) { < > <= >= number= = eq?  and or } ;
: logic-3 ( -- seq ) { between? } ;
: complex-logic-2 ( -- seq ) { number= = eq? and or } ;

: logic-0-test ( -- ) logic-0 nth-rand unit interp-compile-check ;

: integer-logic-1-test ( -- )
    [
        random-integer , logic-1 nth-rand ,
    ] [ ] make interp-compile-check ;

: ratio-logic-1-test ( -- )
    [
        random-ratio , logic-1 nth-rand ,
    ] [ ] make interp-compile-check ;

: float-logic-1-test ( -- )
    [
        random-float , logic-1 nth-rand ,
    ] [ ] make interp-compile-check ;

: complex-logic-1-test ( -- )
    [
        random-complex , logic-1 nth-rand ,
    ] [ ] make interp-compile-check ;


: integer-logic-2-test ( -- )
    [
        random-integer , random-integer , logic-2 nth-rand , 
    ] [ ] make interp-compile-check ;

: ratio-logic-2-test ( -- )
    [
        random-ratio , random-ratio , logic-2 nth-rand , 
    ] [ ] make interp-compile-check ;

: float-logic-2-test ( -- )
    [
        random-float , random-float , logic-2 nth-rand , 
    ] [ ] make interp-compile-check ;

: complex-logic-2-test ( -- )
    [
        random-complex , random-complex , complex-logic-2 nth-rand , 
    ] [ ] make interp-compile-check ;

: test-integer
    {
        
        test-2integer>x test-integer>x test-2integer>x-1 } nth-rand execute ;
! quotation tests
! : test-integer random-integer-quotation interp-compile-check ;
: test-ratio random-ratio-quotation interp-compile-check ;
: test-float random-float-quotation interp-compile-check ;
: test-complex random-complex-quotation interp-compile-check ;



: string-to-math-test ( -- )
    [
        {
        [ random-integer , \ number>string , ]
        [ random-integer , \ number>string , \ string>number , ]
        } do-one
    ] [ ] make interp-compile-check ;




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


: test-random-stack-identity ( -- )
    4 random-stack-identity interp-compile-check* ;


! change the % to make longer quotations
: if-quot ( -- )
    [
        random-ratio , random-ratio , logic-2 nth-rand ,
        2 [ 30% [ if-quot ] [ random-ratio-quotation-1 ] if unit % ] times
        \ if ,
    ] [ ] make ;

: when-quot
    [
        random-ratio , random-ratio , logic-2 nth-rand ,
        90% [ when-quot ] [ random-ratio-quotation-1 ] if unit %
        coin-flip \ when \ unless ? ,
    ] [ ] make ;

: nested-ifs ( -- quot )
    [
        random-ratio ,
        if-quot %
        ! when-quot %
    ] [ ] make ;

: test-if ( -- ) nested-ifs interp-compile-check ;

: random-test ( -- )
    {
        test-if
        test-random-stack-identity
        test-math
    }
    nth-rand execute ;


: watch-simplifier ( -- )
    [
        dup word-def dataflow optimize
        linearize [ split-blocks simplify . ] hash-each
    ] with-compiler ;


