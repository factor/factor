USING: kernel sequences errors namespaces ;
USING: test ;
IN: math

! factorial, nCk, nPk

: (0..n] ( n -- (0..n] ) 1+ 1 swap <range> ; inline
: [1..n] ( n -- [1..n] ) (0..n] ; inline
: [k..n] ( k n -- [k..n] ) 1+ <range> ; inline
: (k..n] ( k n -- (k..n] ) [ 1+ ] 2apply <range> ; inline

! three different notations...bad
: -integer? ( n -- bool )
    #! negative integer
    dup 0 < [ integer? ] [ drop f ] if ;

: Z:(-inf,0]? ( n -- bool )
    #! nonpositive integer
    dup 0 <= [ integer? ] [ drop f ] if ;
    
: natural0? ( n -- bool )
    #! nonnegative integer
    dup 0 >= [ integer? ] [ drop f ] if ;

: natural? ( n -- bool )
    #! positive integer
    dup 0 > [ integer? ] [ drop f ] if ;
    
: factorial ( n -- n! ) (0..n] product ;

: factorial-part ( k! k n -- n! )
    #! calculate n! given n, k, k!
    (k..n] product * ;

: nCk ( n k -- nCk )
    #! uses the results from min(k!,(n-k)!) to compute max(k!,(n-k)!)
    #! use max(k!,(n-k)!) to compute n!
    2dup < [ "n >= k only" throw ] when
    [ - ] 2keep rot 2dup < [ swap ] when
    [ factorial ] keep over
    >r rot [ factorial-part ] keep rot pick >r factorial-part r> r> * / ;

: nPk ( n k -- nPk )
    #! uses the results from (n-k)! to compute n!
    2dup < [ "n >= k only" throw ] when
    2dup - nip [ factorial ] keep rot pick >r factorial-part r> / ;

: binomial ( n k -- nCk )
    #! same as nCk
    nCk ;
    
IN: math-internals
! http://www.rskey.org/gamma.htm  "Lanczos Approximation"
! n=6: error ~ 3 x 10^-11

: gamma-g6 5.15 ; inline

: gamma-p6
    {
        2.50662827563479526904 225.525584619175212544 -268.295973841304927459
        80.9030806934622512966 -5.00757863970517583837 0.0114684895434781459556 
    } ; inline

: gamma-z ( x n -- seq )
    [ [ over + 1.0 swap / , ] each ] { } make 1.0 0 pick set-nth nip ;

: (gamma-lanczos6) ( x -- log[gamma[x+1]] )
    #! log(gamma(x+1)
    dup 0.5 + dup gamma-g6 + dup >r log * r> -
    swap 6 gamma-z gamma-p6 v. log + ;

: gamma-lanczos6 ( x -- gamma[x] )
    #! gamma(x) = gamma(x+1) / x
    dup (gamma-lanczos6) exp swap / ;

: gammaln-lanczos6 ( x -- gammaln[x] )
    #! log(gamma(x)) = log(gamma(x+1)) - log(x)
    dup (gamma-lanczos6) swap log - ;

: gamma-neg ( gamma[abs[x]] x -- gamma[x] )
    dup pi * sin * * pi neg swap / ; inline

IN: math

: gamma ( x -- gamma[x] )
    #! gamma(x) = integral 0..inf [ t^(x-1) exp(-t) ] dt
    #! gamma(n+1) = n! for n > 0
    dup Z:(-inf,0]? [
            drop inf
        ] [
            dup abs gamma-lanczos6 swap dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

: gammaln ( x -- gamma[x] )
    #! gammaln(x) is an alternative when gamma(x)'s range
    #! varies too widely
    dup 0 < [
            drop inf
        ] [
            dup abs gammaln-lanczos6 swap dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

! Tests

: test-factorial 100 [ drop 6000 factorial drop ] each ;
: test-nCk 10 [ drop 10000 5000 nCk drop ] each ;
: test-nPk 10 [ drop 10000 5000 nPk drop ] each ;
: test-gamma 10000 [ drop 10 gamma drop ] each ;

: run-tests
    [ test-factorial ] time 
    [ test-nCk ] time
    [ test-nPk ] time ;

: run-unit-tests
    [ t ] [ 10 3 nPk 10 factorial 7 factorial / = ] unit-test
    [ t ] [ 10 3 nCk 10 factorial 3 factorial 7 factorial * / = ] unit-test
    [ 1 ] [ 0 factorial ] unit-test
    [ 1 ] [ 1 factorial ] unit-test
    [ 2 ] [ 2 factorial ] unit-test
    [ 120 ] [ 5 factorial ] unit-test
    [ 3628800 ] [ 10 factorial ] unit-test
    [ 1 ] [ 1 0 1 factorial-part ] unit-test
    [ 2 ] [ 1 1 2 factorial-part ] unit-test
    [ 1 ] [ 1 1 1 factorial-part ] unit-test
    [ 3628800 ] [ 120 5 10 factorial-part ] unit-test
    [ 1 ] [ 2 2 nCk ] unit-test
    [ 2 ] [ 2 2 nPk ] unit-test
    [ 1 ] [ 2 0 nCk ] unit-test
    [ 1 ] [ 2 0 nPk ] unit-test
    [ t ] [ -9000000000000000000000000000000000000000000 gamma inf = ] unit-test
    [ t ] [ -1.5 gamma 2.36327 - abs .0001 < ] unit-test
    [ t ] [ -1 gamma inf = ] unit-test
    [ t ] [ -0.5 gamma -3.5449 - abs .0001 < ] unit-test
    [ t ] [ 0 gamma inf = ] unit-test
    [ t ] [ .5 gamma 1.7725 - abs .0001 < ] unit-test
    [ t ] [ 1 gamma 1 - abs .0001 < ] unit-test
    [ t ] [ 2 gamma 1 - abs .0001 < ] unit-test
    [ t ] [ 3 gamma 2 - abs .0001 < ] unit-test
    [ t ] [ 11 gamma 3628800 - abs .0001 < ] unit-test
    [ t ] [ 90000000000000000000000000000000000000000000 gamma inf = ] unit-test
    ! some fun identities
    [ t ] [ 2/3 gamma 2 pi * 3 sqrt 1/3 gamma * / - abs .00001 < ] unit-test
    [ t ] [ 3/4 gamma 2 sqrt pi * 1/4 gamma / - abs .0001 < ] unit-test
    [ t ] [ 4/5 gamma 2 5 sqrt / 2 + sqrt pi * 1/5 gamma / - abs .0001 < ] unit-test
    [ t ] [ 3/5 gamma 2 2 5 sqrt / - sqrt pi * 2/5 gamma / - abs .0001 < ] unit-test

    [ t ] [ -90000000000000000000000000000000000000000000 gammaln inf = ] unit-test
    [ t ] [ -1.5 gammaln inf = ] unit-test
    [ t ] [ -1 gammaln inf = ] unit-test
    [ t ] [ -0.5 gammaln inf = ] unit-test
    [ t ] [ 0 gammaln inf = ] unit-test
    [ t ] [ .5 gammaln .5724 - abs .0001 < ] unit-test
    [ t ] [ 1 gammaln 0 - abs .0001 < ] unit-test
    [ t ] [ 2 gammaln 0 - abs .0001 < ] unit-test
    [ t ] [ 3 gammaln 0.6931 - abs .0001 < ] unit-test
    [ t ] [ 11 gammaln 15.1044 - abs .0001 < ] unit-test
    [ t ] [ 9000000000000000000000000000000000000000000 gammaln 8.811521863477754e44 - abs .001 < ] unit-test
    ;

