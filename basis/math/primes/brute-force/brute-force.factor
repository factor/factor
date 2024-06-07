! Copyright (C) 2007-2009 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel make math math.functions math.primes ;
IN: math.primes.brute-force

<PRIVATE

: count-factor ( n d -- n' c )
    [ 1 ] 2dip [ /i ] keep
    [ dupd /mod zero? ] curry [ nip [ 1 + ] dip ] while drop
    swap ;

: write-factor ( n d -- n' d' )
    2dup divisor? [
        [ [ count-factor ] guard 2array , ] keep
        ! If the remainder is a prime number, increase d so that
        ! the caller stops looking for factors.
        over prime? [ drop dup ] when
    ] when ;

PRIVATE>

: brute-force-factors ( n -- seq )
    [
        2
        [ 2dup sq < ] [ write-factor next-prime ] until
        drop dup 2 < [ drop ] [ 1 2array , ] if
    ] { } make ;
