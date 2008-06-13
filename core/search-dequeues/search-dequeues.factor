! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel assocs dequeues dlists hashtables ;
IN: search-dequeues

TUPLE: search-dequeue assoc dequeue ;

C: <search-dequeue> search-dequeue

: <hashed-dlist> ( -- search-dequeue )
    0 <hashtable> <dlist> <search-dequeue> ;

M: search-dequeue dequeue-length dequeue>> dequeue-length ;

M: search-dequeue peek-front dequeue>> peek-front ;

M: search-dequeue peek-back dequeue>> peek-back ;

M: search-dequeue push-front*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ dequeue>> push-front* ] [ assoc>> ] 2bi
        [ 2drop ] [ set-at ] 3bi
    ] if ;

M: search-dequeue push-back*
    2dup assoc>> at* [ 2nip ] [
        drop
        [ dequeue>> push-back* ] [ assoc>> ] 2bi
        [ 2drop ] [ set-at ] 3bi
    ] if ;

M: search-dequeue pop-front*
    [ [ dequeue>> peek-front ] [ assoc>> ] bi delete-at ]
    [ dequeue>> pop-front* ]
    bi ;

M: search-dequeue pop-back*
    [ [ dequeue>> peek-back ] [ assoc>> ] bi delete-at ]
    [ dequeue>> pop-back* ]
    bi ;

M: search-dequeue delete-node
    [ dequeue>> delete-node ]
    [ [ node-value ] [ assoc>> ] bi* delete-at ] 2bi ;

M: search-dequeue clear-dequeue
    [ dequeue>> clear-dequeue ] [ assoc>> clear-assoc ] bi ;

M: search-dequeue dequeue-member?
    assoc>> key? ;

INSTANCE: search-dequeue dequeue
