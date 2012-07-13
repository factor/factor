! Copyright (C) 2007, 2009 Mackenzie Straight, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
deques fry hashtables kernel parser search-deques sequences
summary vocabs.loader ;
IN: dlists

TUPLE: dlist-link { prev maybe{ dlist-link } } { next maybe{ dlist-link } } ;

TUPLE: dlist-node < dlist-link obj ;

M: dlist-link obj>> ;

: new-dlist-link ( obj prev next class -- node )
    new
        swap >>next
        swap >>prev
        swap >>obj ; inline

: <dlist-node> ( obj prev next -- node )
    \ dlist-node new-dlist-link ; inline

TUPLE: dlist
{ front maybe{ dlist-link } }
{ back maybe{ dlist-link } } ;

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

: set-prev-next ( dlist-node -- )
    dup prev>> set-next-when ;

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

PRIVATE>

: unlink-node ( dlist-node -- )
    dup prev>> over next>> set-prev-when
    dup next>> swap prev>> set-next-when ; inline

M: dlist push-front* ( obj dlist -- dlist-node )
    [ front>> f swap <dlist-node> dup dup set-next-prev ] keep
    [ front<< ] keep
    set-back-to-front ;

: push-node-front ( node dlist -- )
    [ front>> >>next drop ]
    [ front<< ]
    [ [ set-next-prev ] [ set-back-to-front ] bi* ] 2tri ;

: push-node-back ( node dlist -- )
    [ back>> >>prev drop ]
    [ back<< ]
    [ [ set-prev-next ] [ set-front-to-back ] bi* ] 2tri ;

M: dlist push-back* ( obj dlist -- dlist-node )
    [ back>> f <dlist-node> ] keep
    [ back>> set-next-when ] 2keep
    [ back<< ] 2keep
    set-front-to-back ;

M: dlist peek-front* ( dlist -- obj/f ? )
    front>> [ obj>> t ] [ f f ] if* ;

M: dlist peek-back* ( dlist -- obj/f ? )
    back>> [ obj>> t ] [ f f ] if* ;

M: dlist pop-front* ( dlist -- )
    [
        [
            [ empty-deque ] unless*
            next>>
            f over set-prev-when
        ] change-front drop
    ] keep
    normalize-back ;

M: dlist pop-back* ( dlist -- )
    [
        [
            [ empty-deque ] unless*
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
    [
        {
            { [ 2dup front>> eq? ] [ nip pop-front* ] }
            { [ 2dup back>> eq? ] [ nip pop-back* ] }
            [ drop unlink-node ]
        } cond
    ] [ drop f >>prev f >>next drop ] 2bi ;

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

: dlist>sequence ( dlist -- seq )
    [ ] collector [ dlist-each ] dip ;

: >dlist ( seq -- dlist )
    <dlist> [ '[ _ push-back ] each ] keep ;

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;

: dlist-filter ( ... dlist quot: ( ... value -- ... ? ) -- ... dlist' )
    [ not ] compose
    <dlist> [ '[ dup obj>> @ [ drop ] [ obj>> _ push-back ] if ] dlist-each-node ] keep ; inline

M: dlist clone
    <dlist> [ '[ _ push-back ] dlist-each ] keep ;

INSTANCE: dlist deque

SYNTAX: DL{ \ } [ >dlist ] parse-literal ;

{ "dlists" "prettyprint" } "dlists.prettyprint" require-when
