! Copyright (C) 2007, 2009 Mackenzie Straight, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences accessors deques
search-deques summary hashtables fry ;
IN: dlists

<PRIVATE

MIXIN: ?dlist-node

INSTANCE: f ?dlist-node

TUPLE: dlist-node obj { prev ?dlist-node } { next ?dlist-node } ;

INSTANCE: dlist-node ?dlist-node

C: <dlist-node> dlist-node

PRIVATE>

TUPLE: dlist
{ front ?dlist-node }
{ back ?dlist-node } ;

: <dlist> ( -- list )
    dlist new ; inline

: <hashed-dlist> ( -- search-deque )
    20 <hashtable> <dlist> <search-deque> ;

M: dlist deque-empty? front>> not ;

M: dlist-node node-value obj>> ;

: set-prev-when ( dlist-node dlist-node/f -- )
    [ (>>prev) ] [ drop ] if* ; inline

: set-next-when ( dlist-node dlist-node/f -- )
    [ (>>next) ] [ drop ] if* ; inline

: set-next-prev ( dlist-node -- )
    dup next>> set-prev-when ; inline

: normalize-front ( dlist -- )
    dup back>> [ f >>front ] unless drop ; inline

: normalize-back ( dlist -- )
    dup front>> [ f >>back ] unless drop ; inline

: set-back-to-front ( dlist -- )
    dup back>> [ dup front>> >>back ] unless drop ; inline

: set-front-to-back ( dlist -- )
    dup front>> [ dup back>> >>front ] unless drop ; inline

: (dlist-find-node) ( dlist-node quot: ( node -- ? ) -- node/f ? )
    over [
        [ call ] 2keep rot
        [ drop t ] [ [ next>> ] dip (dlist-find-node) ] if
    ] [ 2drop f f ] if ; inline recursive

: dlist-find-node ( dlist quot -- node/f ? )
    [ front>> ] dip (dlist-find-node) ; inline

: dlist-each-node ( dlist quot -- )
    '[ @ f ] dlist-find-node 2drop ; inline

: unlink-node ( dlist-node -- )
    dup prev>> over next>> set-prev-when
    dup next>> swap prev>> set-next-when ; inline

PRIVATE>

M: dlist push-front* ( obj dlist -- dlist-node )
    [ front>> f swap <dlist-node> dup dup set-next-prev ] keep
    [ (>>front) ] keep
    set-back-to-front ;

M: dlist push-back* ( obj dlist -- dlist-node )
    [ back>> f <dlist-node> ] keep
    [ back>> set-next-when ] 2keep
    [ (>>back) ] 2keep
    set-front-to-back ;

ERROR: empty-dlist ;

M: empty-dlist summary ( dlist -- )
    drop "Empty dlist" ;

M: dlist peek-front ( dlist -- obj )
    front>> [ obj>> ] [ empty-dlist ] if* ;

M: dlist pop-front* ( dlist -- )
    [
        [
            [ empty-dlist ] unless*
            next>>
            f over set-prev-when
        ] change-front drop
    ] keep
    normalize-back ;

M: dlist peek-back ( dlist -- obj )
    back>> [ obj>> ] [ empty-dlist ] if* ;

M: dlist pop-back* ( dlist -- )
    [
        [
            [ empty-dlist ] unless*
            prev>>
            f over set-next-when
        ] change-back drop
    ] keep
    normalize-front ;

: dlist-find ( dlist quot -- obj/f ? )
    '[ obj>> @ ] dlist-find-node [ obj>> t ] [ drop f f ] if ; inline

: dlist-any? ( dlist quot -- ? )
    dlist-find nip ; inline

M: dlist deque-member? ( value dlist -- ? )
    [ = ] with dlist-any? ;

M: dlist delete-node ( dlist-node dlist -- )
    {
        { [ 2dup front>> eq? ] [ nip pop-front* ] }
        { [ 2dup back>> eq? ] [ nip pop-back* ] }
        [ drop unlink-node ]
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
    '[ obj>> @ ] delete-node-if* drop ; inline

M: dlist clear-deque ( dlist -- )
    f >>front
    f >>back
    drop ;

: dlist-each ( dlist quot -- )
    '[ obj>> @ ] dlist-each-node ; inline

: dlist>seq ( dlist -- seq )
    [ ] accumulator [ dlist-each ] dip ;

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;

: dlist-filter ( dlist quot -- dlist )
    over [ '[ dup obj>> @ [ drop ] [ _ delete-node ] if ] dlist-each-node ] keep ; inline

M: dlist clone
    <dlist> [ '[ _ push-back ] dlist-each ] keep ;

INSTANCE: dlist deque
