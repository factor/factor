! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques kernel ;
IN: search-deques

TUPLE: search-deque assoc deque ;

C: <search-deque> search-deque

M: search-deque deque-empty? deque>> deque-empty? ;

M: search-deque peek-front* deque>> peek-front* ;

M: search-deque peek-back* deque>> peek-back* ;

M: search-deque push-front*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ deque>> push-front* dup ] [ assoc>> set-at ] 2bi
    ] if ;

M: search-deque push-back*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ deque>> push-back* dup ] [ assoc>> set-at ] 2bi
    ] if ;

M: search-deque pop-front*
    [ deque>> pop-front ] [ assoc>> ] bi delete-at ;

M: search-deque pop-back*
    [ deque>> pop-back ] [ assoc>> ] bi delete-at ;

M: search-deque delete-node
    [ deque>> delete-node ]
    [ [ node-value ] [ assoc>> ] bi* delete-at ] 2bi ;

M: search-deque clear-deque
    [ deque>> clear-deque ] [ assoc>> clear-assoc ] bi ;

M: search-deque deque-member?
    assoc>> key? ;

INSTANCE: search-deque deque
