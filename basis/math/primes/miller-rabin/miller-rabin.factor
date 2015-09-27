! Copyright (c) 2008-2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math math.functions math.ranges
random sequences ;
IN: math.primes.miller-rabin

<PRIVATE

:: (miller-rabin) ( n trials -- ? )
    n 1 - :> n-1
    n-1 factor-2s :> ( r s )
    0 :> a!
    trials iota [
        drop
        2 n 2 - [a,b] random a!
        a s n ^mod 1 = [
            f
        ] [
            r iota [
                2^ s * a swap n ^mod n-1 =
            ] any? not
        ] if
    ] any? not ;

PRIVATE>

: miller-rabin* ( n numtrials -- ? )
    {
        { [ over 1 <= ] [ 2drop f ] }
        { [ over even? ] [ drop 2 = ] }
        [ (miller-rabin) ]
    } cond ;

: miller-rabin ( n -- ? ) 10 miller-rabin* ;
