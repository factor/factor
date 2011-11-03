! Copyright (C) 2007, 2009 Mackenzie Straight, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
deques fry hashtables kernel parser search-deques sequences
summary vocabs.loader ;
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

M: dlist deque-empty? front>> not ; inline

M: dlist-node node-value obj>> ;

<PRIVATE

: dlist-nodes= ( dlist-node/f dlist-node/f -- ? )
    {
        [ [ dlist-node? ] both? ]
        [ [ obj>> ] bi@ = ] 
    } 2&& ; inline

PRIVATE>

M: dlist equal?
    over dlist? [
        [ front>> ] bi@
        [ 2dup dlist-nodes= ]
        [ [ next>> ] bi@ ] while 
        or not
    ] [
        2drop f
    ] if ;

: set-prev-when ( dlist-node dlist-node/f -- )
    [ prev<< ] [ drop ] if* ; inline

: set-next-when ( dlist-node dlist-node/f -- )
    [ next<< ] [ drop ] if* ; inline

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

: (dlist-find-node) ( ... dlist-node quot: ( ... node -- ... ? ) -- ... node/f )
    over [
        [ call ] 2keep rot
        [ drop ] [ [ next>> ] dip (dlist-find-node) ] if
    ] [ 2drop f ] if ; inline recursive

: dlist-find-node ( ... dlist quot: ( ... node -- ... ? ) -- ... node/f )
    [ front>> ] dip (dlist-find-node) ; inline

: dlist-find-node-prev ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f ? )
    dlist-find-node [ prev>> ] [ f ] if* ; inline

: dlist-each-node ( ... dlist quot: ( ... node -- ... ) -- ... )
    '[ @ f ] dlist-find-node drop ; inline

: unlink-node ( dlist-node -- )
    dup prev>> over next>> set-prev-when
    dup next>> swap prev>> set-next-when ; inline

PRIVATE>

M: dlist push-front* ( obj dlist -- dlist-node )
    [ front>> f swap <dlist-node> dup dup set-next-prev ] keep
    [ front<< ] keep
    set-back-to-front ;

M: dlist push-back* ( obj dlist -- dlist-node )
    [ back>> f <dlist-node> ] keep
    [ back>> set-next-when ] 2keep
    [ back<< ] 2keep
    set-front-to-back ;

ERROR: empty-dlist ;

M: empty-dlist summary ( dlist -- string )
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

: dlist-find ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f ? )
    '[ obj>> @ ] dlist-find-node [ obj>> t ] [ f f ] if* ; inline

: dlist-any? ( ... dlist quot: ( ... value -- ... ? ) -- ... ? )
    dlist-find nip ; inline

M: dlist deque-member? ( value dlist -- ? )
    [ = ] with dlist-any? ;

M: dlist delete-node ( dlist-node dlist -- )
    {
        { [ 2dup front>> eq? ] [ nip pop-front* ] }
        { [ 2dup back>> eq? ] [ nip pop-back* ] }
        [ drop unlink-node ]
    } cond ;

: delete-node-if* ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f ? )
    dupd dlist-find-node [
        dup [
            [ swap delete-node ] keep obj>> t
        ] [
            2drop f f
        ] if
    ] [
        drop f f
    ] if* ; inline

: delete-node-if ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f )
    '[ obj>> @ ] delete-node-if* drop ; inline

M: dlist clear-deque ( dlist -- )
    f >>front
    f >>back
    drop ;

: dlist-each ( ... dlist quot: ( ... value -- ... ) -- ... )
    '[ obj>> @ ] dlist-each-node ; inline

: dlist>seq ( dlist -- seq )
    [ ] collector [ dlist-each ] dip ;

: seq>dlist ( seq -- dlist )
    <dlist> [ '[ _ push-back ] each ] keep ;

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;

: dlist-filter ( ... dlist quot: ( ... value -- ... ? ) -- ... dlist' )
    over [ '[ dup obj>> @ [ drop ] [ _ delete-node ] if ] dlist-each-node ] keep ; inline

M: dlist clone
    <dlist> [ '[ _ push-back ] dlist-each ] keep ;

INSTANCE: dlist deque

SYNTAX: DL{ \ } [ seq>dlist ] parse-literal ;

{ "dlists" "prettyprint" } "dlists.prettyprint" require-when

