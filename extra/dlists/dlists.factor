! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: dlists
USING: kernel math  ;

! Double-linked lists.

TUPLE: dlist first last ;

: <dlist> dlist construct-empty ;

TUPLE: dlist-node data prev next ;

C: <dlist-node> dlist-node

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

: (dlist-remove) ( dlist quot dnode -- obj/f )
    [
        [ dlist-node-data swap call ] 2keep rot [
            swapd [ (dlist-unlink) ] keep dlist-node-data nip
        ] [
            dlist-node-next (dlist-remove)
        ] if
    ] [
        2drop f
    ] if* ; inline

: dlist-remove ( quot dlist -- obj/f )
    #! Return first item in the dlist that when passed to the
    #! predicate quotation, true is left on the stack. The
    #! item is removed from the dlist. The quotation
    #! must have stack effect ( obj -- bool ).
    #! TODO: needs a better name.
    dup dlist-first swapd (dlist-remove) ; inline

: (dlist-contains?) ( pred dnode -- bool )
    [
        [ dlist-node-data swap call ] 2keep rot [
            2drop t
        ] [
            dlist-node-next (dlist-contains?)
        ] if
    ] [
        drop f
    ] if* ; inline

: dlist-contains? ( quot dlist -- obj/f )
    #! Return true if any item in the dlist that when passed to the
    #! predicate quotation, true is left on the stack.
    #! The 'pred' quotation must have stack effect ( obj -- bool ).
    #! TODO: needs a better name.
    dlist-first (dlist-contains?) ; inline

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
    0 swap [ drop 1+ ] dlist-each ;

