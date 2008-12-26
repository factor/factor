! Copyright (C) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: binary-search combinators kernel lists.lazy math math.functions
    math.miller-rabin math.primes.list sequences ;
IN: math.primes

<PRIVATE

: find-prime-miller-rabin ( n -- p )
    dup miller-rabin [ 2 + find-prime-miller-rabin ] unless ; foldable

PRIVATE>

: next-prime ( n -- p )
    dup 999983 < [
        primes-under-million [ natural-search drop 1+ ] keep nth
    ] [
        next-odd find-prime-miller-rabin
    ] if ; foldable

: prime? ( n -- ? )
    dup 1000000 < [
        dup primes-under-million natural-search nip =
    ] [
        miller-rabin
    ] if ; foldable

: lprimes ( -- list )
    0 primes-under-million seq>list
    1000003 [ 2 + find-prime-miller-rabin ] lfrom-by
    lappend ;

: lprimes-from ( n -- list )
    dup 3 < [ drop lprimes ] [ 1- next-prime [ next-prime ] lfrom-by ] if ;

: primes-upto ( n -- seq )
    {
        { [ dup 2 < ] [ drop { } ] }
        { [ dup 1000003 < ] [
            primes-under-million [ natural-search drop 1+ 0 swap ] keep <slice>
        ] }
        [ lprimes swap [ <= ] curry lwhile list>array ]
    } cond ; foldable

: primes-between ( low high -- seq )
    primes-upto [ 1- next-prime ] dip
    [ natural-search drop ] [ length ] [ ] tri <slice> ; foldable

: coprime? ( a b -- ? ) gcd nip 1 = ; foldable
