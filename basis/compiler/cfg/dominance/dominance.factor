! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators sets math fry kernel math.order
dlists deques namespaces sequences sorting compiler.cfg.rpo ;
IN: compiler.cfg.dominance

! Reference:

! A Simple, Fast Dominance Algorithm
! Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy
! http://www.cs.rice.edu/~keith/EMBED/dom.pdf

! Also, a nice overview is given in these lecture notes:
! http://llvm.cs.uiuc.edu/~vadve/CS526/public_html/Notes/4ssa.4up.pdf

<PRIVATE

! Maps bb -> idom(bb)
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
    [ [ compute-idom ] keep set-idom ] map [ ] any? ;

: compute-dom-parents ( cfg -- )
    H{ } clone dom-parents set
    reverse-post-order
    unclip dup set-idom drop '[ _ iterate ] loop ;

! Maps bb -> {bb' | idom(bb') = bb}
SYMBOL: dom-childrens

PRIVATE>

: dom-children ( bb -- seq ) dom-childrens get at ;

<PRIVATE

: compute-dom-children ( -- )
    dom-parents get H{ } clone
    [ '[ 2dup eq? [ 2drop ] [ _ push-at ] if ] assoc-each ] keep
    dom-childrens set ;

! Maps bb -> DF(bb)
SYMBOL: dom-frontiers

PRIVATE>

: dom-frontier ( bb -- set ) dom-frontiers get at keys ;

<PRIVATE

: compute-dom-frontier ( bb pred -- )
    2dup [ dom-parent ] dip eq? [ 2drop ] [
        [ dom-frontiers get conjoin-at ]
        [ dom-parent compute-dom-frontier ] 2bi
    ] if ;

: compute-dom-frontiers ( cfg -- )
    H{ } clone dom-frontiers set
    [
        dup predecessors>> dup length 2 >= [
            [ compute-dom-frontier ] with each
        ] [ 2drop ] if
    ] each-basic-block ;

PRIVATE>

: compute-dominance ( cfg -- )
    [ compute-dom-parents compute-dom-children ]
    [ compute-dom-frontiers ]
    bi ;

<PRIVATE

SYMBOLS: work-list visited ;

: add-to-work-list ( bb -- )
    dom-frontier work-list get push-all-front ;

: iterated-dom-frontier-step ( bb -- )
    dup visited get key? [ drop ] [
        [ visited get conjoin ]
        [ add-to-work-list ] bi
    ] if ;

PRIVATE>

: iterated-dom-frontier ( bbs -- bbs' )
    [
        <dlist> work-list set
        H{ } clone visited set
        [ add-to-work-list ] each
        work-list get [ iterated-dom-frontier-step ] slurp-deque
        visited get keys
    ] with-scope ;