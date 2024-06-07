! Copyright (C) 2007, 2009 Mackenzie Straight, Doug Coleman,
! Slava Pestov, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit deques
hashtables kernel kernel.private math math.order parser
search-deques sequences vocabs.loader ;
IN: dlists

TUPLE: dlist-link
    { prev maybe{ dlist-link } }
    { next maybe{ dlist-link } } ;

TUPLE: dlist-node < dlist-link obj ;

M: dlist-link obj>> ;

M: dlist-link node-value obj>> ;

: new-dlist-link ( obj prev next class -- node )
    new
        swap >>next
        swap >>prev
        swap >>obj ; inline

: <dlist-node> ( obj prev next -- dlist-node )
    \ dlist-node new-dlist-link ; inline

TUPLE: dlist
    { front maybe{ dlist-link } }
    { back maybe{ dlist-link } } ;

: <dlist> ( -- list )
    dlist new ; inline

: <hashed-dlist> ( -- search-deque )
    20 <hashtable> <dlist> <search-deque> ;

M: dlist deque-empty? front>> not ; inline

M: dlist equal?
    over dlist? [
        [ front>> ] bi@
        [ 2dup { [ and ] [ [ obj>> ] same? ] } 2&& ]
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
        [ call ] 2guard
        [ drop ] [ [ next>> ] dip (dlist-find-node) ] if
    ] [ 2drop f ] if ; inline recursive

: dlist-find-node ( ... dlist quot: ( ... node -- ... ? ) -- ... node/f )
    [ front>> ] dip (dlist-find-node) ; inline

: dlist-find-node-prev ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f ? )
    dlist-find-node [ prev>> ] [ f ] if* ; inline

: dlist-each-node ( ... dlist quot: ( ... node -- ... ) -- ... )
    '[ @ f ] dlist-find-node drop ; inline

: unlink-node ( dlist-node -- )
    [ prev>> ] [ next>> ] bi
    [ set-prev-when ]
    [ swap set-next-when ] 2bi ; inline

M: dlist push-front*
    [
        f swap <dlist-node> dup dup set-next-prev
    ] change-front set-back-to-front ;

: push-node-front ( dlist-node dlist -- )
    dupd [ >>next ] change-front
    [ set-next-prev ] [ set-back-to-front ] bi* ;

: push-node-back ( dlist-node dlist -- )
    dupd [ >>prev ] change-back
    [ set-prev-next ] [ set-front-to-back ] bi* ;

M: dlist push-back*
    [
        [ f <dlist-node> dup dup ]
        [ set-next-when ] bi
    ] change-back set-front-to-back ;

M: dlist peek-front*
    front>> [ obj>> t ] [ f f ] if* ;

M: dlist peek-back*
    back>> [ obj>> t ] [ f f ] if* ;

M: dlist pop-front*
    [
        [ empty-deque ] unless*
        next>>
        f over set-prev-when
    ] change-front normalize-back ;

M: dlist pop-back*
    [
        [ empty-deque ] unless*
        prev>>
        f over set-next-when
    ] change-back normalize-front ;

: dlist-find ( ... dlist quot: ( ... value -- ... ? ) -- ... obj/f ? )
    '[ obj>> @ ] dlist-find-node [ obj>> t ] [ f f ] if* ; inline

: dlist-any? ( ... dlist quot: ( ... value -- ... ? ) -- ... ? )
    dlist-find nip ; inline

M: dlist deque-member?
    [ = ] with dlist-any? ;

M: dlist delete-node
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

M: dlist clear-deque
    f >>front f >>back drop ;

: dlist-length ( dlist -- n )
    0 swap [
        drop { fixnum } declare 1 + f
    ] dlist-find-node drop ; flushable

: dlist-each ( ... dlist quot: ( ... value -- ... ) -- ... )
    '[ obj>> @ ] dlist-each-node ; inline

: dlist>sequence ( dlist -- seq )
    [ ] collector [ dlist-each ] dip ;

: >dlist ( seq -- dlist )
    <dlist> [ '[ _ push-back ] each ] keep ;

: 1dlist ( obj -- dlist ) <dlist> [ push-front ] keep ;

: dlist-filter ( ... dlist quot: ( ... value -- ... ? ) -- ... dlist' )
    <dlist> [
        '[ _ guard [ _ push-back ] [ drop ] if ] dlist-each
    ] keep ; inline

M: dlist clone
    <dlist> [ '[ _ push-back ] dlist-each ] keep ;

<PRIVATE

: (push-before-node) ( obj dlist-node -- new-dlist-node )
    [ [ prev>> ] keep <dlist-node> dup ] keep
    [ dupd next<< ] change-prev drop ; inline

: push-before-node ( obj dlist-node dlist -- new-dlist-node )
    2dup front>> eq? [
        nip push-front*
    ] [
        drop (push-before-node)
    ] if ; inline

PRIVATE>

: push-before ( ... obj dlist quot: ( ... obj -- ... ? ) -- ... dlist-node )
    [ obj>> ] prepose over [ dlist-find-node ] dip swap
    [ swap push-before-node ] [ push-back* ] if* ; inline

: push-sorted ( obj dlist -- dlist-node )
    dupd [ before? ] with push-before ; inline

INSTANCE: dlist deque

SYNTAX: DL{ \ } [ >dlist ] parse-literal ;

{ "dlists" "prettyprint" } "dlists.prettyprint" require-when
