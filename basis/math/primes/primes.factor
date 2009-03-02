! Copyright (C) 2007-2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.functions math.miller-rabin
math.order math.primes.erato math.ranges sequences ;
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
    next-odd [ dup really-prime? ] [ 2 + ] until ; foldable

: primes-between ( low high -- seq )
    [ dup 3 max dup even? [ 1 + ] when ] dip
    2 <range> [ prime? ] filter
    swap 3 < [ 2 prefix ] when ;

: primes-upto ( n -- seq ) 2 swap primes-between ;

: coprime? ( a b -- ? ) gcd nip 1 = ; foldable
