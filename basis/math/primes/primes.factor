! Copyright (C) 2007-2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.bitwise math.functions
math.order math.primes.erato math.primes.erato.private
math.primes.miller-rabin math.ranges literals random sequences sets ;
IN: math.primes

<PRIVATE

: look-in-bitmap ( n -- ? ) $[ 8999999 sieve ] marked-unsafe? ; inline

: (prime?) ( n -- ? )
    dup 8999999 <= [ look-in-bitmap ] [ miller-rabin ] if ;

PRIVATE>

: prime? ( n -- ? )
    {
        { [ dup 7 < ] [ { 2 3 5 } member? ] }
        { [ dup even? ] [ 2 = ] }
        [ (prime?) ]
    } cond ; foldable

: next-prime ( n -- p )
    dup 2 < [
        drop 2
    ] [
        next-odd [ dup prime? ] [ 2 + ] until
    ] if ; foldable

: primes-between ( low high -- seq )
    [ dup 3 max dup even? [ 1 + ] when ] dip
    2 <range> [ prime? ] filter
    swap 3 < [ 2 prefix ] when ;

: primes-upto ( n -- seq ) 2 swap primes-between ;

: coprime? ( a b -- ? ) gcd nip 1 = ; foldable

: random-prime ( numbits -- p )
    random-bits* next-prime ;

: estimated-primes ( m -- n )
    dup log / ; foldable

ERROR: no-relative-prime n ;

<PRIVATE

: (find-relative-prime) ( n guess -- p )
    over 1 <= [ over no-relative-prime ] when
    dup 1 <= [ drop 3 ] when
    2dup gcd nip 1 > [ 2 + (find-relative-prime) ] [ nip ] if ;

PRIVATE>

: find-relative-prime* ( n guess -- p )
    #! find a prime relative to n with initial guess
    >odd (find-relative-prime) ;

: find-relative-prime ( n -- p )
    dup random find-relative-prime* ;

ERROR: too-few-primes n numbits ;

: unique-primes ( n numbits -- seq )
    2dup 2^ estimated-primes > [ too-few-primes ] when
    2dup [ random-prime ] curry replicate
    dup all-unique? [ 2nip ] [ drop unique-primes ] if ;
