! Copyright (C) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel lazy-lists math math.primes namespaces sequences ;
IN: math.primes.factors

<PRIVATE

: (factor) ( n d -- n' )
    2dup mod zero? [ [ / ] keep dup , (factor) ] [ drop ] if ;

: (count) ( n d -- n' )
    [ (factor) ] { } make
    dup empty? [ drop ] [ [ first ] keep length 2array , ] if ;

: (unique) ( n d -- n' )
    [ (factor) ] { } make
    dup empty? [ drop ] [ first , ] if ;

: (factors) ( quot list n -- )
    dup 1 > [ swap uncons >r pick call r> swap (factors) ] [ 3drop ] if ;

: (decompose) ( n quot -- seq )
    [ lprimes rot (factors) ] { } make ;

PRIVATE>

: factors ( n -- seq )
    [ (factor) ] (decompose) ; foldable

: count-factors ( n -- seq )
    [ (count) ] (decompose) ; foldable

: unique-factors ( n -- seq )
    [ (unique) ] (decompose) ; foldable

: totient ( n -- t )
    dup 2 < [
        drop 0
    ] [
        dup unique-factors dup 1 [ 1- * ] reduce swap product / *
    ] if ; foldable
