! Copyright (C) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: dlists USING: generic kernel math ;

! Double-linked lists.

TUPLE: dlist first last ;
TUPLE: dlist-node next prev data ;

C: dlist ;
C: dlist-node
    [ set-dlist-node-next ] keep
    [ set-dlist-node-prev ] keep
    [ set-dlist-node-data ] keep ;

: dlist-push-end ( data dlist -- )
    [ dlist-last f <dlist-node> ] keep
    [ dlist-last [ dupd set-dlist-node-next ] when* ] keep
    2dup set-dlist-last
    dup dlist-first [ 2drop ] [ set-dlist-first ] ifte ;

: dlist-empty? ( dlist -- ? )
    dlist-first f = ;

: (dlist-pop-front) ( dlist -- data )
    [ dlist-first dlist-node-data ] keep
    [ dup dlist-first dlist-node-next swap set-dlist-first ] keep
    dup dlist-first [ drop ] [ f swap set-dlist-last ] ifte ;

: dlist-pop-front ( dlist -- data )
    dup dlist-empty? [ drop f ] [ (dlist-pop-front) ] ifte ;
