! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators.short-circuit grouping kernel math
math.combinatorics math.functions math.order math.primes
math.ranges math.statistics math.vectors memoize sequences ;

IN: math.extras

<PRIVATE

DEFER: sterling

: (sterling) ( n k -- x )
    [ [ 1 - ] bi@ sterling ]
    [ [ 1 - ] dip sterling ]
    [ nip * + ] 2tri ;

PRIVATE>

MEMO: sterling ( n k -- x )
    2dup { [ = ] [ nip 1 = ] } 2||
    [ 2drop 1 ] [ (sterling) ] if ;

<PRIVATE

DEFER: bernoulli

: (bernoulli) ( p -- n )
    [ iota ] [ 1 + ] bi [
        0 [ [ nCk ] [ bernoulli * ] bi + ] with reduce
    ] keep recip neg * ;

PRIVATE>

MEMO: bernoulli ( p -- n )
    [ 1 ] [ (bernoulli) ] if-zero ;

: chi2 ( actual expected -- n )
    0 [ dup 0 > [ [ - sq ] keep / + ] [ 2drop ] if ] 2reduce ;

<PRIVATE

: df-check ( df -- )
    even? [ "odd degrees of freedom" throw ] unless ;

: (chi2P) ( chi/2 df/2 -- p )
    [1,b) dupd n/v cum-product swap neg e^ [ v*n sum ] keep + ;

PRIVATE>

: chi2P ( chi df -- p )
    dup df-check [ 2.0 / ] [ 2 /i ] bi* (chi2P) 1.0 min ;

<PRIVATE

: check-jacobi ( m -- m )
    dup { [ integer? ] [ 0 > ] [ odd? ] } 1&&
    [ "modulus must be odd positive integer" throw ] unless ;

: mod' ( x y -- n )
    [ mod ] keep over zero? [ drop ] [
        2dup [ sgn ] same? [ drop ] [ + ] if
    ] if ;

PRIVATE>

: jacobi ( a m -- n )
    check-jacobi [ mod' ] keep 1
    [ pick zero? ] [
        [ pick even? ] [
            [ 2 / ] 2dip
            over 8 mod' { 3 5 } member? [ neg ] when
        ] while swapd
        2over [ 4 mod' 3 = ] both? [ neg ] when
        [ [ mod' ] keep ] dip
    ] until [ nip 1 = ] dip 0 ? ;

<PRIVATE

: check-legendere ( m -- m )
    dup prime? [ "modulus must be prime positive integer" throw ] unless ;

PRIVATE>

: legendere ( a m -- n )
    check-legendere jacobi ;

: moving-average ( seq n -- newseq )
    <clumps> [ mean ] map ;

: exponential-moving-average ( seq a -- newseq )
    [ 1 ] 2dip [ [ dupd swap - ] dip * + dup ] curry map nip ;

: moving-median ( u n -- v )
    <clumps> [ median ] map ;

: nonzero ( seq -- seq' )
    [ zero? not ] filter ;
