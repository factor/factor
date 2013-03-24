! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays bit-sets fry
hashtables hints kernel locals math namespaces sequences sets
compiler.cfg compiler.cfg.dominance compiler.cfg.rpo ;
FROM: namespaces => set ;
FROM: assocs => change-at ;
IN: compiler.cfg.ssa.construction.tdmsc

! TDMSC-I algorithm from "A Practical and Fast Iterative Algorithm for
! Phi-Function Computation Using DJ Graphs"

! http://portal.acm.org/citation.cfm?id=1065887.1065890

<PRIVATE

SYMBOLS: visited merge-sets levels again? ;

: init-merge-sets ( cfg -- )
    post-order dup length '[ _ <bit-set> ] H{ } map>assoc merge-sets set ;

: compute-levels ( cfg -- )
    0 over entry>> associate [
        '[
            _ [ [ dom-parent ] dip at 1 + ] 2keep set-at
        ] each-basic-block
    ] keep levels set ;

: j-edge? ( from to -- ? )
    2dup eq? [ 2drop f ] [ dominates? not ] if ;

: level ( bb -- n ) levels get at ; inline

: update-merge-set ( tmp to -- )
    [ merge-sets get ] dip
    '[
        _
        [ merge-sets get at union ]
        [ number>> over adjoin ]
        bi
    ] change-at ;

:: walk ( tmp to lnode -- lnode )
    tmp level to level >= [
        tmp to update-merge-set
        tmp dom-parent to tmp walk
    ] [ lnode ] if ;

: each-incoming-j-edge ( ... bb quot: ( ... from to -- ... ) -- ... )
    [ [ predecessors>> ] keep ] dip
    '[ _ 2dup j-edge? _ [ 2drop ] if ] each ; inline

: visited? ( pair -- ? ) visited get in? ;

: consistent? ( snode lnode -- ? )
    [ merge-sets get at ] bi@ subset? ;

: (process-edge) ( from to -- )
    f walk [
        2dup 2array visited? [
            consistent? [ again? on ] unless
        ] [ 2drop ] if
    ] each-incoming-j-edge ;

: process-edge ( from to -- )
    2dup 2array dup visited? [ 3drop ] [
        visited get adjoin
        (process-edge)
    ] if ;

: process-block ( bb -- )
    [ process-edge ] each-incoming-j-edge ;

: compute-merge-set-step ( bfo -- )
    HS{ } clone visited set
    [ process-block ] each ;

: compute-merge-set-loop ( cfg -- )
    breadth-first-order
    '[ again? off _ compute-merge-set-step again? get ]
    loop ;

: (merge-set) ( bbs -- flags rpo )
    merge-sets get '[ _ at ] [ union ] map-reduce
    cfg get reverse-post-order ; inline

PRIVATE>

: compute-merge-sets ( cfg -- )
    needs-dominance

    [ compute-levels ]
    [ init-merge-sets ]
    [ compute-merge-set-loop ]
    tri ;

: merge-set ( bbs -- bbs' )
     (merge-set) [ members ] dip nths ;
