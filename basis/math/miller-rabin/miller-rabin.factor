! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math math.functions math.ranges
random sequences sets combinators.short-circuit math.bitwise ;
IN: math.miller-rabin

<PRIVATE

: >odd ( n -- int ) dup even? [ 1 + ] when ; foldable

: >even ( n -- int ) 0 clear-bit ; foldable

TUPLE: positive-even-expected n ;

:: (miller-rabin) ( n trials -- ? )
    n 1 - :> n-1
    n-1 factor-2s :> s :> r
    0 :> a!
    trials [
        drop
        n 1 - [1,b] random a!
        a s n ^mod 1 = [
            f
        ] [
            r iota [
                2^ s * a swap n ^mod n - -1 =
            ] any? not 
        ] if
    ] any? not ;

PRIVATE>

: next-odd ( m -- n ) dup even? [ 1 + ] [ 2 + ] if ;

: miller-rabin* ( n numtrials -- ? )
    over {
        { [ dup 1 <= ] [ 3drop f ] }
        { [ dup 2 = ] [ 3drop t ] }
        { [ dup even? ] [ 3drop f ] }
        [ drop (miller-rabin) ]
    } cond ;

: miller-rabin ( n -- ? ) 10 miller-rabin* ;

: next-prime ( n -- p )
    next-odd dup miller-rabin [ next-prime ] unless ;

: random-prime ( numbits -- p )
    random-bits next-prime ;

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

ERROR: too-few-primes ;

: unique-primes ( numbits n -- seq )
    #! generate two primes
    swap
    dup 5 < [ too-few-primes ] when
    2dup [ random-prime ] curry replicate
    dup all-unique? [ 2nip ] [ drop unique-primes ] if ;

! Safe primes are of the form p = 2q + 1, p,q are prime
! See http://en.wikipedia.org/wiki/Safe_prime

<PRIVATE

: >safe-prime-form ( q -- p ) 2 * 1 + ;

: safe-prime-candidate? ( n -- ? )
    >safe-prime-form
    1 + 6 divisor? ;

: next-safe-prime-candidate ( n -- candidate )
    next-prime dup safe-prime-candidate?
    [ next-safe-prime-candidate ] unless ;

PRIVATE>

: safe-prime? ( q -- ? )
    {
        [ 1 - 2 / dup integer? [ miller-rabin ] [ drop f ] if ]
        [ miller-rabin ]
    } 1&& ;

: next-safe-prime ( n -- q )
    1 - >even 2 /
    next-safe-prime-candidate
    dup >safe-prime-form
    dup miller-rabin
    [ nip ] [ drop next-safe-prime ] if ;

: random-bits* ( numbits -- n )
    [ random-bits ] keep set-bit ;

: random-safe-prime ( numbits -- p )
    1- random-bits* next-safe-prime ;
