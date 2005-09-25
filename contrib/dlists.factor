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
    dup dlist-first [ 2drop ] [ set-dlist-first ] if ;

: dlist-empty? ( dlist -- ? )
    dlist-first f = ;
    
: (unlink-prev) ( dlist dnode -- )
    dup dlist-node-prev [
        dupd swap dlist-node-next swap set-dlist-node-next
    ] when*
    2dup swap dlist-first eq? [ 
        dlist-node-next swap set-dlist-first 
    ] [ 2drop ] if ;

: (unlink-next) ( dlist dnode -- )
    dup dlist-node-next [
        dupd swap dlist-node-prev swap set-dlist-node-prev
    ] when*
    2dup swap dlist-last eq? [
        dlist-node-prev swap set-dlist-last
    ] [ 2drop ] if ;

: (dlist-unlink) ( dlist dnode -- )
    [ (unlink-prev) ] 2keep (unlink-next) ;

: (dlist-pop-front) ( dlist -- data )
    [ dlist-first dlist-node-data ] keep dup dlist-first (dlist-unlink) ;

: dlist-pop-front ( dlist -- data )
    dup dlist-empty? [ drop f ] [ (dlist-pop-front) ] if ;

: (dlist-each) ( quot dnode -- )
    [
        [ dlist-node-data swap call ] 2keep 
        dlist-node-next (dlist-each)
    ] [
        drop
    ] if* ; inline

: dlist-each ( dlist quot -- )
    swap dlist-first (dlist-each) ; inline

: dlist-length ( dlist -- length )
    0 swap [ drop 1 + ] dlist-each ;
