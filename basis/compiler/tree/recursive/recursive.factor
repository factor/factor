! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs arrays namespaces accessors sequences deques
search-deques dlists compiler.tree compiler.tree.combinators ;
IN: compiler.tree.recursive

! Collect label info
GENERIC: collect-label-info ( node -- )

M: #return-recursive collect-label-info
    dup label>> (>>return) ;

M: #call-recursive collect-label-info
    dup label>> calls>> push ;

M: #recursive collect-label-info
    label>> V{ } clone >>calls drop ;

M: node collect-label-info drop ;

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
    [
        [
            label>>
            [ swap 2array loop-stack [ swap suffix ] change ]
            [ remember-loop-info ]
            [ t >>loop? drop ]
            tri
        ]
        [ t swap child>> (collect-loop-info) ] bi
    ] with-scope ;

: current-loop-nesting ( label -- alist )
    loop-stack get swap loop-heights get at tail ;

: disqualify-loop ( label -- )
    work-list get push-front ;

M: #call-recursive collect-loop-info*
    label>>
    swap [ dup disqualify-loop ] unless
    dup current-loop-nesting
    [ keys [ loop-calls get push-at ] with each ]
    [ [ nip not ] assoc-filter keys [ disqualify-loop ] each ]
    bi ;

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

: analyze-recursive ( nodes -- nodes )
    dup [ collect-label-info ] each-node
    dup collect-loop-info disqualify-loops ;
