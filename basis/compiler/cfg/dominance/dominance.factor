! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators sets math fry kernel math.order
dlists deques vectors namespaces sequences sorting locals
compiler.cfg.rpo compiler.cfg.predecessors ;
FROM: namespaces => set ;
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

: compute-dominance ( cfg -- cfg' )
    [ compute-dom-parents compute-dom-children ] [ compute-dfs ] [ ] tri ;

PRIVATE>

: needs-dominance ( cfg -- cfg' )
    needs-predecessors
    dup dominance-valid?>> [ compute-dominance t >>dominance-valid? ] unless ;

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
