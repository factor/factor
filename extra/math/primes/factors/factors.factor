! Copyright (C) 2007-2009 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel lists make math math.primes sequences ;
IN: math.primes.factors

<PRIVATE

: count-factor ( n d -- n' c )
    0 [ [ 2dup mod zero? ] dip swap ] [ [ [ / ] keep ] dip 1+ ] [ ] while nip ;

: (factor) ( n d -- n' ) dup [ , ] curry [ count-factor ] dip times ;

: (count) ( n d -- n' )
    dup [ swap 2array , ] curry
    [ count-factor dup zero? [ drop ] ] dip if ;

: (unique) ( n d -- n' )
    dup [ , ] curry [ count-factor zero? ] dip unless ;

: (factors) ( quot list n -- )
    dup 1 > [
        swap uncons swap [ pick call ] dip swap (factors)
    ] [ 3drop ] if ; inline recursive

: decompose ( n quot -- seq ) [ lprimes rot (factors) ] { } make ; inline

PRIVATE>

: factors ( n -- seq ) [ (factor) ] decompose ; flushable

: group-factors ( n -- seq ) [ (count) ] decompose ; flushable

: unique-factors ( n -- seq ) [ (unique) ] decompose ; flushable

: totient ( n -- t )
    dup 2 < [
        drop 0
    ] [
        dup unique-factors [ 1 [ 1- * ] reduce ] [ product ] bi / *
    ] if ; foldable
