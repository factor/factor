! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques hashtables heaps kernel ;
IN: assoc-deques

TUPLE: assoc-deque assoc deque ;

C: <assoc-deque> assoc-deque

: <unique-min-heap> ( -- unique-heap )
    H{ } clone <min-heap> <assoc-deque> ;

: <unique-max-heap> ( -- unique-heap )
    H{ } clone <max-heap> <assoc-deque> ;

M: assoc-deque heap-push* ( value key assoc-deque -- entry )
    pick over assoc>> key? [
        3drop f
    ] [
        [ assoc>> swapd set-at ] [ deque>> heap-push* ] 3bi
    ] if ;

M: assoc-deque heap-pop ( assoc-deque -- value key )
    [ deque>> heap-pop ] keep
    [ over ] dip assoc>> delete-at ;

M: assoc-deque heap-peek ( assoc-deque -- value key )
    deque>> heap-peek ;

M: assoc-deque heap-empty? ( assoc-deque -- value key )
    deque>> heap-empty? ;
