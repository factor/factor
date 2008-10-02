! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables heaps kernel ;
IN: assoc-heaps

TUPLE: assoc-heap assoc heap ;

C: <assoc-heap> assoc-heap

: <unique-min-heap> ( -- unique-heap )
    H{ } clone <min-heap> <assoc-heap> ;

: <unique-max-heap> ( -- unique-heap )
    H{ } clone <max-heap> <assoc-heap> ;

M: assoc-heap heap-push* ( value key assoc-heap -- entry )
    pick over assoc>> key? [
        3drop f
    ] [
        [ assoc>> swapd set-at ] [ heap>> heap-push* ] 3bi
    ] if ;

M: assoc-heap heap-pop ( assoc-heap -- value key )
    heap>> heap-pop ;

M: assoc-heap heap-peek ( assoc-heap -- value key )
    heap>> heap-peek ;

M: assoc-heap heap-empty? ( assoc-heap -- value key )
    heap>> heap-empty? ;
