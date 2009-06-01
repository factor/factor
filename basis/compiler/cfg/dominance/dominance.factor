! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.rpo
compiler.cfg.stack-analysis fry kernel math.order namespaces
sequences ;
IN: compiler.cfg.dominance

! Reference:

! A Simple, Fast Dominance Algorithm
! Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy
! http://www.cs.rice.edu/~keith/EMBED/dom.pdf

SYMBOL: idoms

: idom ( bb -- bb' ) idoms get at ;

<PRIVATE

: set-idom ( idom bb -- changed? ) idoms get maybe-set-at ;

: intersect ( finger1 finger2 -- bb )
    2dup [ number>> ] compare {
        { +lt+ [ [ idom ] dip intersect ] }
        { +gt+ [ idom intersect ] }
        [ 2drop ]
    } case ;

: compute-idom ( bb -- idom )
    predecessors>> [ idom ] map sift
    [ ] [ intersect ] map-reduce ;

: iterate ( rpo -- changed? )
    [ [ compute-idom ] keep set-idom ] map [ ] any? ;

PRIVATE>

: compute-dominance ( cfg -- cfg )
    H{ } clone idoms set
    dup reverse-post-order
    unclip dup set-idom drop '[ _ iterate ] loop ;