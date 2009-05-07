! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math math.functions math.ranges
random sequences sets combinators.short-circuit math.bitwise
math math.order ;
IN: math.miller-rabin

<PRIVATE

: >odd ( n -- int ) 0 set-bit ; foldable

: >even ( n -- int ) 0 clear-bit ; foldable

: next-even ( m -- n ) >even 2 + ;

: next-odd ( m -- n ) dup even? [ 1 + ] [ 2 + ] if ;

TUPLE: positive-even-expected n ;

:: (miller-rabin) ( n trials -- ? )
    n 1 - :> n-1
    n-1 factor-2s :> s :> r
    0 :> a!
    trials [
        drop
        2 n 2 - [a,b] random a!
        a s n ^mod 1 = [
            f
        ] [
            r iota [
                2^ s * a swap n ^mod n - -1 =
            ] any? not 
        ] if
    ] any? not ;

PRIVATE>

: miller-rabin* ( n numtrials -- ? )
    over {
        { [ dup 1 <= ] [ 3drop f ] }
        { [ dup 2 = ] [ 3drop t ] }
        { [ dup even? ] [ 3drop f ] }
        [ drop (miller-rabin) ]
    } cond ;

: miller-rabin ( n -- ? ) 10 miller-rabin* ;

ERROR: prime-range-error n ;

: next-prime ( n -- p )
    dup 1 < [ prime-range-error ] when
    dup 1 = [
        drop 2
    ] [
        next-odd dup miller-rabin [ next-prime ] unless
    ] if ;

: random-bits* ( numbits -- n )
    1 - [ random-bits ] keep set-bit ;

: random-prime ( numbits -- p )
    random-bits* next-prime ;

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

: safe-prime-candidate? ( n -- ? )
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
    next-safe-prime-candidate
    dup safe-prime? [ next-safe-prime ] unless ;

: random-safe-prime ( numbits -- p )
    random-bits* next-safe-prime ;
