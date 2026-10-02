! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs deques dlists kernel locals math mirrors sequences ;
IN: dlists.mirrors

TUPLE: dlist-mirror { object read-only } ;
C: <dlist-mirror> dlist-mirror
INSTANCE: dlist-mirror assoc

<PRIVATE

:: mirror-node ( key mirror -- node/f )
    key integer? [ key 0 >= ] [ f ] if [
        mirror object>> front>> :> node!
        key :> index!
        [ node index 0 > and ] [
            node next>> node!
            index 1 - index!
        ] while node
    ] [ f ] if ;

PRIVATE>

M: dlist-mirror at*
    mirror-node [ obj>> t ] [ f f ] if* ;

M:: dlist-mirror set-at ( value key mirror -- )
    key mirror mirror-node
    [ value swap obj<< ] [ key no-such-slot ] if* ;

M:: dlist-mirror delete-at ( key mirror -- )
    key mirror mirror-node [ mirror object>> delete-node ] when* ;

M: dlist-mirror clear-assoc object>> clear-deque ;
M: dlist-mirror assoc-size object>> dlist-length ;
M: dlist-mirror keys assoc-size <iota> >array ;
M: dlist-mirror values object>> dlist>sequence >array ;
M: dlist-mirror >alist values <enumerated> >array ;

M: dlist make-mirror <dlist-mirror> ;
