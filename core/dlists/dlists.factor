! Copyright (C) 2007, 2008 Mackenzie Straight, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences accessors summary
dequeues ;
IN: dlists

TUPLE: dlist front back length ;

: <dlist> ( -- obj )
    dlist new
        0 >>length ;

M: dlist dequeue-length length>> ;

<PRIVATE

TUPLE: dlist-node obj prev next ;

C: <dlist-node> dlist-node

M: dlist-node node-value obj>> ;

: inc-length ( dlist -- )
    [ 1+ ] change-length drop ; inline

: dec-length ( dlist -- )
    [ 1- ] change-length drop ; inline

: set-prev-when ( dlist-node dlist-node/f -- )
    [ (>>prev) ] [ drop ] if* ;

: set-next-when ( dlist-node dlist-node/f -- )
    [ (>>next) ] [ drop ] if* ;

: set-next-prev ( dlist-node -- )
    dup next>> set-prev-when ;

: normalize-front ( dlist -- )
    dup back>> [ f >>front ] unless drop ;

: normalize-back ( dlist -- )
    dup front>> [ f >>back ] unless drop ;

: set-back-to-front ( dlist -- )
    dup back>> [ dup front>> >>back ] unless drop ;

: set-front-to-back ( dlist -- )
    dup front>> [ dup back>> >>front ] unless drop ;

: (dlist-find-node) ( dlist-node quot -- node/f ? )
    over [
        [ call ] 2keep rot
        [ drop t ] [ >r next>> r> (dlist-find-node) ] if
    ] [ 2drop f f ] if ; inline

: dlist-find-node ( dlist quot -- node/f ? )
    >r front>> r> (dlist-find-node) ; inline

: dlist-each-node ( dlist quot -- )
    [ f ] compose dlist-find-node 2drop ; inline

: unlink-node ( dlist-node -- )
    dup prev>> over next>> set-prev-when
    dup next>> swap prev>> set-next-when ;

PRIVATE>

M: dlist push-front* ( obj dlist -- dlist-node )
    [ front>> f swap <dlist-node> dup dup set-next-prev ] keep
    [ (>>front) ] keep
    [ set-back-to-front ] keep
    inc-length ;

M: dlist push-back* ( obj dlist -- dlist-node )
    [ back>> f <dlist-node> ] keep
    [ back>> set-next-when ] 2keep
    [ (>>back) ] 2keep
    [ set-front-to-back ] keep
    inc-length ;

ERROR: empty-dlist ;

M: empty-dlist summary ( dlist -- )
    drop "Empty dlist" ;

M: dlist peek-front ( dlist -- obj )
    front>> [ obj>> ] [ empty-dlist ] if* ;

M: dlist pop-front* ( dlist -- )
    dup front>> [ empty-dlist ] unless
    [
        dup front>>
        dup next>>
        f rot (>>next)
        f over set-prev-when
        swap (>>front)
    ] keep
    [ normalize-back ] keep
    dec-length ;

M: dlist peek-back ( dlist -- obj )
    back>> [ obj>> ] [ empty-dlist ] if* ;

M: dlist pop-back* ( dlist -- )
    dup back>> [ empty-dlist ] unless
    [
        dup back>>
        dup prev>>
        f rot (>>prev)
        f over set-next-when
        swap (>>back)
    ] keep
    [ normalize-front ] keep
    dec-length ;

: dlist-find ( dlist quot -- obj/f ? )
    [ obj>> ] prepose
    dlist-find-node [ obj>> t ] [ drop f f ] if ; inline

: dlist-contains? ( dlist quot -- ? )
    dlist-find nip ; inline

M: dlist dequeue-member? ( value dlist -- ? )
    [ = ] curry dlist-contains? ;

M: dlist delete-node ( dlist-node dlist -- )
    {
        { [ 2dup front>> eq? ] [ nip pop-front* ] }
        { [ 2dup back>> eq? ] [ nip pop-back* ] }
        [ dec-length unlink-node ]
    } cond ;

: delete-node-if* ( dlist quot -- obj/f ? )
    dupd dlist-find-node [
        dup [
            [ swap delete-node ] keep obj>> t
        ] [
            2drop f f
        ] if
    ] [
        2drop f f
    ] if ; inline

: delete-node-if ( dlist quot -- obj/f )
    [ obj>> ] prepose delete-node-if* drop ; inline

M: dlist clear-dequeue ( dlist -- )
    f >>front
    f >>back
    0 >>length
    drop ;

: dlist-each ( dlist quot -- )
    [ obj>> ] prepose dlist-each-node ; inline

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;

INSTANCE: dlist dequeue
