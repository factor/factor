! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays bit-sets fry
hashtables hints kernel locals math namespaces sequences sets
compiler.cfg compiler.cfg.dominance compiler.cfg.rpo ;
IN: compiler.cfg.ssa.construction.tdmsc

! TDMSC-I algorithm from "A Practical and Fast Iterative Algorithm for
! Phi-Function Computation Using DJ Graphs"

! http://portal.acm.org/citation.cfm?id=1065887.1065890

<PRIVATE

SYMBOLS: visited merge-sets levels again? ;

: init-merge-sets ( cfg -- )
    post-order dup length '[ _ <bit-array> ] H{ } map>assoc merge-sets set ;

: compute-levels ( cfg -- )
    0 over entry>> associate [
        '[
            _ [ [ dom-parent ] dip at 1 + ] 2keep set-at
        ] each-basic-block
    ] keep levels set ;

: j-edge? ( from to -- ? )
    2dup eq? [ 2drop f ] [ dominates? not ] if ;

: level ( bb -- n ) levels get at ; inline

: set-bit ( bit-array n -- )
    [ t ] 2dip swap set-nth ;

: update-merge-set ( tmp to -- )
    [ merge-sets get ] dip
    '[
        _
        [ merge-sets get at bit-set-union ]
        [ dupd number>> set-bit ]
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

: visited? ( pair -- ? ) visited get key? ;

: consistent? ( snode lnode -- ? )
    [ merge-sets get at ] bi@ swap bit-set-subset? ;

: (process-edge) ( from to -- )
    f walk [
        2dup 2array visited? [
            consistent? [ again? on ] unless
        ] [ 2drop ] if
    ] each-incoming-j-edge ;

: process-edge ( from to -- )
    2dup 2array dup visited? [ 3drop ] [
        visited get conjoin
        (process-edge)
    ] if ;

: process-block ( bb -- )
    [ process-edge ] each-incoming-j-edge ;

: compute-merge-set-step ( bfo -- )
    visited get clear-assoc
    [ process-block ] each ;

: compute-merge-set-loop ( cfg -- )
    breadth-first-order
    '[ again? off _ compute-merge-set-step again? get ]
    loop ;

: (merge-set) ( bbs -- flags rpo )
    merge-sets get '[ _ at ] [ bit-set-union ] map-reduce
    cfg get reverse-post-order ; inline

: filter-by ( flags seq -- seq' )
    [ drop ] selector [ 2each ] dip ;

HINTS: filter-by { bit-array object } ;

PRIVATE>

: compute-merge-sets ( cfg -- )
    needs-dominance

    H{ } clone visited set
    [ compute-levels ]
    [ init-merge-sets ]
    [ compute-merge-set-loop ]
    tri ;

: merge-set-each ( ... bbs quot: ( ... bb -- ... ) -- ... )
    [ (merge-set) ] dip '[
        swap _ [ drop ] if
    ] 2each ; inline

: merge-set ( bbs -- bbs' )
     (merge-set) filter-by ;
