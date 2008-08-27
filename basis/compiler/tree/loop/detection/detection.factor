! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces assocs accessors fry
compiler.tree deques search-deques ;
IN: compiler.tree.loop.detection

! A loop is a #recursive which only tail calls itself, and those
! calls are nested inside other loops only. We optimistically
! assume all #recursive nodes are loops, disqualifying them as
! we see evidence to the contrary.

: (tail-calls) ( tail? seq -- seq' )
    reverse [ swap [ and ] keep ] map nip reverse ;

: tail-calls ( tail? node -- seq )
    [
        [ #phi? ]
        [ #return? ]
        [ #return-recursive? ]
        tri or or
    ] map (tail-calls) ;

SYMBOL: loop-heights
SYMBOL: loop-calls
SYMBOL: loop-stack
SYMBOL: work-list

GENERIC: collect-loop-info* ( tail? node -- )

: non-tail-label-info ( nodes -- )
    [ f swap collect-loop-info* ] each ;

: (collect-loop-info) ( tail? nodes -- )
    [ tail-calls ] keep [ collect-loop-info* ] 2each ;

: remember-loop-info ( label -- )
    loop-stack get length swap loop-heights get set-at ;

M: #recursive collect-loop-info*
    nip
    [
        [
            label>>
            [ loop-stack [ swap suffix ] change ]
            [ remember-loop-info ]
            [ t >>loop? drop ]
            tri
        ]
        [ t swap child>> (collect-loop-info) ] bi
    ] with-scope ;

: current-loop-nesting ( label -- labels )
    loop-stack get swap loop-heights get at tail ;

: disqualify-loop ( label -- )
    work-list get push-front ;

M: #call-recursive collect-loop-info*
    label>>
    swap [ dup disqualify-loop ] unless
    dup current-loop-nesting [ loop-calls get push-at ] with each ;

M: #if collect-loop-info*
    children>> [ (collect-loop-info) ] with each ;

M: #dispatch collect-loop-info*
    children>> [ (collect-loop-info) ] with each ;

M: node collect-loop-info* 2drop ;

: collect-loop-info ( node -- )
    { } loop-stack set
    H{ } clone loop-calls set
    H{ } clone loop-heights set
    <hashed-dlist> work-list set
    t swap (collect-loop-info) ;

: disqualify-loops ( -- )
    work-list get [
        dup loop?>> [
            [ f >>loop? drop ]
            [ loop-calls get at [ disqualify-loop ] each ]
            bi
        ] [ drop ] if
    ] slurp-deque ;

: detect-loops ( nodes -- nodes )
    dup collect-loop-info disqualify-loops ;
