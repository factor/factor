! Copyright (C) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: binary-search combinators kernel lists.lazy math math.functions
math.miller-rabin math.primes.erato math.ranges sequences ;
IN: math.primes

<PRIVATE

: look-in-bitmap ( n -- ? ) >index 4999999 sieve nth ;

: really-prime? ( n -- ? )
    dup 5000000 < [ look-in-bitmap ] [ miller-rabin ] if ; foldable

PRIVATE>

: prime? ( n -- ? )
    {
        { [ dup 2 < ] [ drop f ] }
        { [ dup even? ] [ 2 = ] }
        [ really-prime? ]
    } cond ; foldable

: next-prime ( n -- p )
    next-odd [ dup really-prime? ] [ 2 + ] [ ] until ; foldable

: lprimes ( -- list ) 2 [ next-prime ] lfrom-by ;

: lprimes-from ( n -- list )
    dup 3 < [ drop lprimes ] [ 1- next-prime [ next-prime ] lfrom-by ] if ;

: primes-upto ( n -- seq )
    dup 2 < [
        drop V{ }
    ] [
        3 swap 2 <range> [ prime? ] filter 2 prefix
    ] if ; foldable

: primes-between ( low high -- seq )
    primes-upto [ 1- next-prime ] dip
    [ natural-search drop ] [ length ] [ ] tri <slice> ; foldable

: coprime? ( a b -- ? ) gcd nip 1 = ; foldable
