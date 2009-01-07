! Copyright (C) 2007-2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel make math math.primes sequences ;
IN: math.primes.factors

<PRIVATE

: count-factor ( n d -- n' c )
    [ 1 ] 2dip [ /i ] keep
    [ dupd /mod zero? ] curry [ nip [ 1+ ] dip ] [ drop ] while
    swap ;

: write-factor ( n d -- n' d )
    2dup mod zero? [ [ [ count-factor ] keep swap 2array , ] keep ] when ;

PRIVATE>

: group-factors ( n -- seq )
    [ 2 [ over 1 > ] [ write-factor next-prime ] [ ] while 2drop ] { } make ;

: unique-factors ( n -- seq ) group-factors [ first ] map ;

: factors ( n -- seq ) group-factors [ first2 swap <array> ] map concat ;

: totient ( n -- t )
    {
        { [ dup 2 < ] [ drop 0 ] }
        [ dup unique-factors [ 1 [ 1- * ] reduce ] [ product ] bi / * ]
    } cond ; foldable
