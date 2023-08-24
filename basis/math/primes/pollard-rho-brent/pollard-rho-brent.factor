! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel make math math.order math.primes
ranges random sorting ;
IN: math.primes.pollard-rho-brent

! https://comeoncodeon.wordpress.com/2010/09/18/pollard-rho-brent-integer-factorization/
:: (brent-factor) ( n -- factor )
    n [1..b) random
    n [1..b) random
    n [1..b) random :> ( y! c m )
    1 1 1 :> ( g! r! q! )
    0 :> x!
    0 :> ys!
    [ g 1 = ] [
        y x!
        r [
            y sq n mod c + n mod y!
        ] times
        0 :> k!
        [ k r < g 1 = and ] [
            y ys!
            m r k - min [
                y sq n mod c + n mod y!
                x y - abs q * n mod q!
            ] times
            q n gcd nip g!
            k m + k!
        ] while
        r 2 * r!
    ] while
    g n = [
        [ g 1 > not ] [
            ys sq n mod c + n mod ys!
            x ys - abs n gcd nip g!
        ] while
    ] when
    g ;

: brent-factor ( n -- factor )
    dup even? [ drop 2 ] [ (brent-factor) ] if ;

DEFER: pollard-rho-brent-factors

! 0) can hang if given a large prime, so check prime? first
! 1) brent-factor can return a composite number
! 2) also it can hang if you give it a prime number
! 3) factors can be found in random order
! therefore we check these conditions
:: (pollard-rho-brent-factors) ( n! -- )
    n brent-factor :> factor
    ! 1) check for prime
    factor prime? [
        factor ,
    ] [
        factor pollard-rho-brent-factors %
    ] if
    n factor = [
        n factor /i
        ! 2) check for prime
        dup prime? [ , ] [ (pollard-rho-brent-factors) ] if
    ] unless ;

: pollard-rho-brent-factors ( n! -- factors )
    dup 1 <= [
        drop { }
    ] [
        dup prime? [
            1array
        ] [
            [ (pollard-rho-brent-factors) ] { } make
        ] if
    ] if sort ;
