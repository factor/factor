! Copyright (C) 2007, 2008 Mackenzie Straight, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences accessors ;
IN: dlists

TUPLE: dlist front back length ;

: <dlist> ( -- obj )
    dlist new
    0 >>length ;

: dlist-empty? ( dlist -- ? ) front>> not ;

<PRIVATE

TUPLE: dlist-node obj prev next ;

C: <dlist-node> dlist-node

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

PRIVATE>

: push-front* ( obj dlist -- dlist-node )
    [ front>> f swap <dlist-node> dup dup set-next-prev ] keep
    [ (>>front) ] keep
    [ set-back-to-front ] keep
    inc-length ;

: push-front ( obj dlist -- )
    push-front* drop ;

: push-all-front ( seq dlist -- )
    [ push-front ] curry each ;

: push-back* ( obj dlist -- dlist-node )
    [ back>> f <dlist-node> ] keep
    [ back>> set-next-when ] 2keep
    [ (>>back) ] 2keep
    [ set-front-to-back ] keep
    inc-length ;

: push-back ( obj dlist -- )
    push-back* drop ;

: push-all-back ( seq dlist -- )
    [ push-back ] curry each ;

: peek-front ( dlist -- obj )
    front>> dup [ obj>> ] when ;

: pop-front ( dlist -- obj )
    dup front>> [
        dup next>>
        f rot (>>next)
        f over set-prev-when
        swap (>>front)
    ] 2keep obj>>
    swap [ normalize-back ] keep dec-length ;

: pop-front* ( dlist -- )
    pop-front drop ;

: peek-back ( dlist -- obj )
    back>> dup [ obj>> ] when ;

: pop-back ( dlist -- obj )
    dup back>> [
        dup prev>>
        f rot (>>prev)
        f over set-next-when
        swap (>>back)
    ] 2keep obj>>
    swap [ normalize-front ] keep dec-length ;

: pop-back* ( dlist -- )
    pop-back drop ;

: dlist-find ( dlist quot -- obj/f ? )
    [ obj>> ] prepose
    dlist-find-node [ obj>> t ] [ drop f f ] if ; inline

: dlist-contains? ( dlist quot -- ? )
    dlist-find nip ; inline

: unlink-node ( dlist-node -- )
    dup prev>> over next>> set-prev-when
    dup next>> swap prev>> set-next-when ;

: delete-node ( dlist dlist-node -- )
    {
        { [ over front>> over eq? ] [ drop pop-front* ] }
        { [ over back>> over eq? ] [ drop pop-back* ] }
        [ unlink-node dec-length ]
    } cond ;

: delete-node-if* ( dlist quot -- obj/f ? )
    dupd dlist-find-node [
        dup [
            [ delete-node ] keep obj>> t
        ] [
            2drop f f
        ] if
    ] [
        2drop f f
    ] if ; inline

: delete-node-if ( dlist quot -- obj/f )
    [ obj>> ] prepose
    delete-node-if* drop ; inline

: dlist-delete ( obj dlist -- obj/f )
    swap [ eq? ] curry delete-node-if ;

: dlist-delete-all ( dlist -- )
    f >>front
    f >>back
    0 >>length
    drop ;

: dlist-each ( dlist quot -- )
    [ obj>> ] prepose dlist-each-node ; inline

: dlist-slurp ( dlist quot -- )
    over dlist-empty?
    [ 2drop ] [ [ >r pop-back r> call ] 2keep dlist-slurp ] if ;
    inline

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;
