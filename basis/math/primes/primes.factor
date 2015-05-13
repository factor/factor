! Copyright (C) 2007-2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit fry kernel math
math.bitwise math.functions math.order math.primes.erato
math.primes.erato.private math.primes.miller-rabin math.ranges
literals random sequences sets vectors ;
IN: math.primes

<PRIVATE

: look-in-bitmap ( n -- ? )
    $[ 8999999 sieve ] marked-unsafe? ; inline

: (prime?) ( n -- ? )
    dup 8999999 <= [ look-in-bitmap ] [ miller-rabin ] if ;

! In order not to reallocate large vectors, we compute the upper bound
! of the number of primes in a given interval. We use a double inequality given
! by Pierre Dusart in http://www.ams.org/mathscinet-getitem?mr=99d:11133
! for x > 598. Under this limit, we know that there are at most 108 primes.
: upper-pi ( x -- y )
    dup log [ / ] [ 1.2762 swap / 1 + ] bi * ceiling ;

: lower-pi ( x -- y )
    dup log [ / ] [ 0.992 swap / 1 + ] bi * floor ;

: <primes-vector> ( low high -- vector )
    swap [ [ upper-pi ] [ lower-pi ] bi* - >integer
    108 max 10000 min <vector> ] keep
    3 < [ 2 suffix! ] when ;

: simple? ( n -- ? ) { [ even? ] [ 3 divisor? ] [ 5 divisor? ] } 1|| ;

PRIVATE>

: prime? ( n -- ? )
    {
        { [ dup 7 < ] [ { 2 3 5 } member? ] }
        { [ dup simple? ] [ drop f ] }
        [ (prime?) ]
    } cond ; foldable

: next-prime ( n -- p )
    dup 2 < [
        drop 2
    ] [
        next-odd [ dup prime? ] [ 2 + ] until
    ] if ; foldable

<PRIVATE

: (primes-between) ( low high -- seq )
    [ [ 3 max dup even? [ 1 + ] when ] dip 2 <range> ]
    [ <primes-vector> ] 2bi
    [ '[ [ prime? ] _ push-if ] each ] keep clone ;

PRIVATE>

: primes-between ( low high -- seq )
    [ ceiling >integer ] [ floor >integer ] bi*
    {
        { [ 2dup > ] [ 2drop V{ } clone ] }
        { [ dup 2 = ] [ 2drop V{ 2 } clone ] }
        { [ dup 2 < ] [ 2drop V{ } clone ] }
        [ (primes-between) ]
    } cond ;

: primes-upto ( n -- seq ) 2 swap primes-between ;

: nprimes ( n -- seq ) 2 swap [ [ next-prime ] keep ] replicate nip ;

: coprime? ( a b -- ? ) fast-gcd 1 = ; foldable

: random-prime ( numbits -- p )
    [ ] [ 2^ ] [ random-bits* next-prime ] tri
    2dup < [ 2drop random-prime ] [ 2nip ] if ;

: estimated-primes ( m -- n )
    dup log / ; foldable

ERROR: no-relative-prime n ;

<PRIVATE

: (find-relative-prime) ( n guess -- p )
    over 1 <= [ over no-relative-prime ] when
    dup 1 <= [ drop 3 ] when
    [ 2dup coprime? ] [ 2 + ] until nip ;

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
