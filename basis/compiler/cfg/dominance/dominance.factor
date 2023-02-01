! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.predecessors
compiler.cfg.rpo deques dlists kernel math math.order
namespaces sequences sorting vectors ;
IN: compiler.cfg.dominance

<PRIVATE

SYMBOL: dom-parents

PRIVATE>

: dom-parent ( bb -- bb' ) dom-parents get at ;

<PRIVATE

: set-idom ( idom bb -- changed? )
    dom-parents get maybe-set-at ;

: intersect ( finger1 finger2 -- bb )
    2dup [ number>> ] compare {
        { +gt+ [ [ dom-parent ] dip intersect ] }
        { +lt+ [ dom-parent intersect ] }
        [ 2drop ]
    } case ;

: compute-idom ( bb -- idom )
    predecessors>> [ dom-parent ] filter
    [ ] [ intersect ] map-reduce ;

: iterate ( rpo -- changed? )
    f [ [ compute-idom ] keep set-idom or ] reduce ;

: compute-dom-parents ( cfg -- )
    H{ } clone dom-parents set
    reverse-post-order
    unclip dup set-idom drop '[ _ iterate ] loop ;

SYMBOL: dom-childrens

PRIVATE>

: dom-children ( bb -- seq ) dom-childrens get at ;

<PRIVATE

: compute-dom-children ( dom-parents -- dom-childrens )
    H{ } clone [ '[ 2dup eq? [ 2drop ] [ _ push-at ] if ] assoc-each ] keep
    [ [ number>> ] sort-by ] assoc-map ;

SYMBOLS: preorder maxpreorder ;

PRIVATE>

: pre-of ( bb -- n ) [ preorder get at ] [ -1/0. ] if* ;

: maxpre-of ( bb -- n ) [ maxpreorder get at ] [ 1/0. ] if* ;

<PRIVATE

: (compute-dfs) ( n bb -- n )
    [ 1 + ] dip
    [ dupd preorder get set-at ]
    [ dom-children [ (compute-dfs) ] each ]
    [ dupd maxpreorder get set-at ]
    tri ;

: compute-dfs ( cfg -- )
    H{ } clone preorder set
    H{ } clone maxpreorder set
    [ 0 ] dip entry>> (compute-dfs) drop ;

: compute-dominance ( cfg -- )
    [
        compute-dom-parents
        dom-parents get compute-dom-children dom-childrens set
    ] [ compute-dfs ] bi ;

PRIVATE>

: needs-dominance ( cfg -- )
    [ needs-predecessors ]
    [
        dup dominance-valid?>> [ drop ]
        [ t >>dominance-valid? compute-dominance ] if
    ] bi ;

: dominates? ( bb1 bb2 -- ? )
    swap [ pre-of ] [ [ pre-of ] [ maxpre-of ] bi ] bi* between? ;

:: breadth-first-order ( cfg -- bfo )
    <dlist> :> work-list
    cfg post-order length <vector> :> accum
    cfg entry>> work-list push-front
    work-list [
        [ accum push ]
        [ dom-children work-list push-all-front ] bi
    ] slurp-deque
    accum ;
