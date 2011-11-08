! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel assocs deques ;
IN: search-deques

TUPLE: search-deque assoc deque ;

C: <search-deque> search-deque

M: search-deque deque-empty? deque>> deque-empty? ;

M: search-deque peek-front* deque>> peek-front* ;

M: search-deque peek-back* deque>> peek-back* ;

M: search-deque push-front*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ deque>> push-front* ] [ assoc>> ] 2bi
        [ 2drop ] [ set-at ] 3bi
    ] if ;

M: search-deque push-back*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ deque>> push-back* ] [ assoc>> ] 2bi
        [ 2drop ] [ set-at ] 3bi
    ] if ;

M: search-deque pop-front*
    [ [ deque>> peek-front ] [ assoc>> ] bi delete-at ]
    [ deque>> pop-front* ]
    bi ;

M: search-deque pop-back*
    [ [ deque>> peek-back ] [ assoc>> ] bi delete-at ]
    [ deque>> pop-back* ]
    bi ;

M: search-deque delete-node
    [ deque>> delete-node ]
    [ [ node-value ] [ assoc>> ] bi* delete-at ] 2bi ;

M: search-deque clear-deque
    [ deque>> clear-deque ] [ assoc>> clear-assoc ] bi ;

M: search-deque deque-member?
    assoc>> key? ;

INSTANCE: search-deque deque
