! Copyright (C) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel lists make math math.primes sequences ;
IN: math.primes.factors

<PRIVATE

: (factor) ( n d -- n' )
    2dup mod zero? [ [ / ] keep dup , (factor) ] [ drop ] if ;

: (count) ( n d -- n' )
    [ (factor) ] { } make
    [ [ first ] [ length ] bi 2array , ] unless-empty ;

: (unique) ( n d -- n' )
    [ (factor) ] { } make
    [ first , ] unless-empty ;

: (factors) ( quot list n -- )
    dup 1 > [
        swap uncons swap [ pick call ] dip swap (factors)
    ] [ 3drop ] if ;

: (decompose) ( n quot -- seq )
    [ lprimes rot (factors) ] { } make ;

PRIVATE>

: factors ( n -- seq )
    [ (factor) ] (decompose) ; foldable

: group-factors ( n -- seq )
    [ (count) ] (decompose) ; foldable

: unique-factors ( n -- seq )
    [ (unique) ] (decompose) ; foldable

: totient ( n -- t )
    dup 2 < [
        drop 0
    ] [
        dup unique-factors [ 1 [ 1- * ] reduce ] [ product ] bi / *
    ] if ; foldable
