! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math math.functions
math.primes random ;
IN: math.primes.safe

<PRIVATE

: safe-prime-candidate? ( n -- ? )
    1 + 6 divisor? ;

: next-safe-prime-candidate ( n -- candidate )
    next-prime dup safe-prime-candidate?
    [ next-safe-prime-candidate ] unless ;

PRIVATE>

: safe-prime? ( q -- ? )
    {
        [ 1 - 2 / dup integer? [ prime? ] [ drop f ] if ]
        [ prime? ]
    } 1&& ;

: next-safe-prime ( n -- q )
    next-safe-prime-candidate
    dup safe-prime? [ next-safe-prime ] unless ;

: random-safe-prime ( numbits -- p )
    random-bits* next-safe-prime ;
