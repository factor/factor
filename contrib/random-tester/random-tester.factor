USING: kernel math math-internals sequences namespaces errors hashtables words
       arrays parser compiler syntax lists io ;
USING: inspector prettyprint ;
USING: optimizer inference ;
IN: random-tester

! n-foo>bar -- list of words of type 'foo' that take n parameters
!              and output a 'bar'


! Math vocabulary words
: 1-x>y ( -- seq )
    #! Words that take one argument
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        bitnot bits>double bits>float ceiling cis conjugate cos cosec cosech
        cosh cot coth denominator double>bits exp float>bits floor imaginary
        log neg next-power-of-2 numerator quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;

: 1-x>y-throws
    #! Words that take one argument and possibly throw an error
    {
        recip log2
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;

: 2-x>y ( -- seq )
    #! Words that take two arguments
    { * + - /f max min polar> bitand bitor bitxor align } ;

: 2-x>y-throws ( -- seq )
    #! Words that take two arguments and possibly throw an error
    { / /i mod rem } ;

: 1-integer>x
    #! Words that take an integer and output a type (not necessarily integer)
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        bitnot bits>double bits>float ceiling cis conjugate cos cosec cosech
        cosh cot coth denominator double>bits exp float>bits floor imaginary
        log neg next-power-of-2 numerator quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;

: 1-ratio>x
    {
        1+ 1- >bignum >digit >fixnum abs absq arg ceiling
        cis conjugate cos cosec cosech
        cosh cot coth double>bits exp float>bits floor imaginary
        log neg next-power-of-2 quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate 
    } ;

: 1-float>x ( float -- x )
    {
        1+ 1- >bignum >digit >fixnum abs absq arg 
        ceiling cis conjugate cos cosec cosech
        cosh cot coth double>bits exp float>bits floor imaginary
        log neg next-power-of-2 quadrant real sec
        sech sgn sin sinh sq sqrt tan tanh truncate
    } ;

: 1-complex>x
    {
        1+ 1- abs absq arg conjugate cos cosec cosech
        cosh cot coth exp imaginary log neg quadrant real
        sec sech sin sinh sq sqrt tan tanh 
    } ;

: 1-integer>x-throws
    {
        recip log2
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;

: 1-ratio>x-throws
    {
        recip
        asec asech acot acoth acosec acosech acos acosh asin asinh atan atanh
    } ;

: 1-integer>integer
    #! Subset of 1-integer>x
    {
        1+ 1- >bignum >digit >fixnum abs absq 
        bitnot ceiling conjugate 
        denominator double>bits float>bits floor imaginary
        neg next-power-of-2 numerator quadrant
        real sgn sq truncate 
    } ;

: 1-ratio>ratio
    { 1+ 1- >digit abs absq conjugate neg real sq } ;

: 1-float>float
    {
        1+ 1- >digit abs absq arg ceiling
        conjugate exp floor neg real sq truncate
    } ;

: 1-complex>complex
    {
        1+ 1- abs absq arg 
        conjugate cosec cosech
        cosh cot coth exp 
        log neg quadrant 
        sech sin sinh sq sqrt tanh 
    } ;

: 2-integer>x ( n n -- x )
    { * + - /f max min polar> bitand bitor bitxor align } ;
: 2-ratio>x ( r r -- x )
    { * + - /f max min polar> } ;
: 2-float>x ( f f -- x )
    { float+ float- float* float/f + - * /f max min polar> } ;
: 2-complex>x ( c c -- x ) { * + - /f } ;

: 2-integer>integer ( n n -- n )
    { * + - max min bitand bitor bitxor align } ;
: 2-ratio>ratio ( r r -- r )
    { * + - max min } ;
: 2-float>float ( f f -- f ) 
    { float* float+ float- float/f max min /f + - } ;
: 2-complex>complex ( c c -- c )
    { * + - /f } ;






SYMBOL: last-quot
SYMBOL: first-arg
SYMBOL: second-arg
: 0-runtime-check ( quot -- )
    #! Checks the runtime only, not the compiler
    #! Evaluates the quotation twice and makes sure the results agree
    [ last-quot set ] keep
    [ call ] keep
    call
    ! 2dup swap unparse write " " write unparse print
    = [ last-quot get . "problem in runtime" throw ] unless ;

: 1-runtime-check ( quot -- )
    #! Checks the runtime only, not the compiler
    #! Evaluates the quotation twice and makes sure the results agree
    #! For quotations that are given one argument
    [ last-quot set first-arg set ] 2keep
    [ call ] 2keep
    call
    2dup swap unparse write " " write unparse print
    = [ "problem in runtime" throw ] unless ;

: 1-interpreted-vs-compiled-check ( x quot -- ) 
    #! Checks the runtime output vs the compiler output
    #! quot: ( x -- y )
    2dup swap unparse write " " write .
    [ last-quot set first-arg set ] 2keep
    [ call ] 2keep compile-1
    2dup swap unparse write " " write unparse print
    = [ "problem in math1" throw ] unless ;

: 2-interpreted-vs-compiled-check ( x y quot -- )
    #! Checks the runtime output vs the compiler output
    #! quot: ( x y -- z )
    .s flush
    [ last-quot set first-arg set second-arg set ] 3keep
    [ call ] 3keep compile-1
    2dup swap unparse write " " write unparse print
    = [ "problem in math2" throw ] unless ;

: 0-interpreted-vs-compiled-check-catch ( quot -- )
    #! Check the runtime output vs the compiler output for words that throw
    #!
    dup .
    [ last-quot set ] keep
    [ catch [ "caught: " write dup print-error ] when* ] keep 
    [ compile-1 ] catch [ nip "caught: " write dup print-error ] when*
    = [ "problem in math3" throw ] unless ;

: 1-interpreted-vs-compiled-check-catch ( quot -- )
    #! Check the runtime output vs the compiler output for words that throw
    2dup swap unparse write " " write .
    ! "." write
    [ last-quot set first-arg set ] 2keep
    [ catch [ nip "caught: " write dup print-error ] when* ] 2keep 
    [ compile-1 ] catch [ 2nip "caught: " write dup print-error ] when*
    = [ "problem in math4" throw ] unless ;

: 2-interpreted-vs-compiled-check-catch ( quot -- )
    #! Check the runtime output vs the compiler output for words that throw
    ! 3dup rot unparse write " " write swap unparse write " " write .
    "." write
    [ last-quot set first-arg set second-arg set ] 3keep
    [ catch [ 2nip "caught: " write dup print-error ] when* ] 3keep
    [ compile-1 ] catch [ 2nip nip "caught: " write dup print-error ] when*
    = [ "problem in math5" throw ] unless ;


! RANDOM QUOTATIONS TO TEST
: random-1-integer>x-quot ( -- quot ) 1-integer>x nth-rand unit ;
: random-1-ratio>x-quot ( -- quot ) 1-ratio>x nth-rand unit ;
: random-1-float>x-quot ( -- quot ) 1-float>x nth-rand unit ;
: random-1-complex>x-quot ( -- quot ) 1-complex>x nth-rand unit ;

: test-1-integer>x ( -- )
    random-integer random-1-integer>x-quot 1-interpreted-vs-compiled-check ;
: test-1-ratio>x ( -- )
    random-ratio random-1-ratio>x-quot 1-interpreted-vs-compiled-check ;
: test-1-float>x ( -- )
    random-float random-1-float>x-quot 1-interpreted-vs-compiled-check ;
: test-1-complex>x ( -- )
    random-complex random-1-complex>x-quot 1-interpreted-vs-compiled-check ;


: random-1-float>float-quot ( -- ) 1-float>float nth-rand unit ;
: random-2-float>float-quot ( -- ) 2-float>float nth-rand unit ;
: nrandom-2-float>float-quot ( -- )
    [
        5
        [
            {
                [ 2-float>float nth-rand , random-float , ]
                [ 1-float>float nth-rand ,  ]
            } do-one
        ] times 
        2-float>float nth-rand ,
    ] [ ] make ;

: test-1-float>float ( -- )
    random-float random-1-float>float-quot 1-interpreted-vs-compiled-check ;
: test-2-float>float ( -- )
    random-float random-float random-2-float>float-quot
    2-interpreted-vs-compiled-check ;

: test-n-2-float>float ( -- )
    random-float random-float nrandom-2-float>float-quot
    2-interpreted-vs-compiled-check ;

: test-1-integer>x-runtime ( -- )
    random-integer random-1-integer>x-quot 1-runtime-check ;

: random-1-integer>x-throws-quot ( -- ) 1-integer>x-throws nth-rand unit ;
: random-1-ratio>x-throws-quot ( -- ) 1-ratio>x-throws nth-rand unit ;
: test-1-integer>x-throws ( -- )
    random-integer random-1-integer>x-throws-quot
    1-interpreted-vs-compiled-check-catch ;
: test-1-ratio>x-throws ( -- )
    random-ratio random-1-ratio>x-throws-quot
    1-interpreted-vs-compiled-check-catch ;



: test-2-integer>x-throws ( -- )
    [
        random-integer , random-integer ,
        2-x>y-throws nth-rand ,
    ] [ ] make 2-interpreted-vs-compiled-check-catch ;

! : test-^-shift ( -- )
!    [
        ! 100 random-int 50 - ,
        ! 100 random-int 50 - ,
        ! { ^ shift } nth-rand ,
    ! ] [ ] make 2-interpreted-vs-compiled-check-catch ;

! : test-^-ratio ( -- )
    ! [
        ! random-ratio , random-ratio , \ ^ ,
    ! ] [ ] make interp-compile-check-catch ;

: test-0-float?-when
    [
        random-number , \ dup , \ float? , 1-float>x nth-rand unit , \ when ,
    ] [ ] make 0-runtime-check ;

: test-1-integer?-when
    random-float [
        \ dup , \ float? , 1-float>x nth-rand unit , \ when ,
    ] [ ] make 1-interpreted-vs-compiled-check ;

: test-1-ratio?-when
    random-ratio [
        \ dup , \ ratio? , 1-ratio>x nth-rand unit , \ when ,
    ] [ ] make 1-interpreted-vs-compiled-check ;

: test-1-float?-when
    random-float [
        \ dup , \ float? , 1-float>x nth-rand unit , \ when ,
    ] [ ] make 1-interpreted-vs-compiled-check ;

: test-1-complex?-when
    random-complex [
        \ dup , \ complex? , 1-complex>x nth-rand unit , \ when ,
    ] [ ] make 1-interpreted-vs-compiled-check ;

: random-test
    {
        test-1-integer>x
        test-1-ratio>x
        test-1-float>x
        test-1-complex>x
        test-1-integer>x-throws
        test-1-ratio>x-throws
        test-1-float>float
        test-2-float>float
        test-n-2-float>float
        test-1-integer>x-runtime
        ! test-0-float?-when
        test-1-integer?-when
        test-1-ratio?-when
        test-1-float?-when
        test-1-complex?-when
    } nth-rand execute ;

