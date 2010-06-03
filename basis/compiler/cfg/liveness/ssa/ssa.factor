! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces deques accessors sets sequences assocs fry
hashtables dlists compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.rpo compiler.cfg.liveness compiler.cfg.utilities
compiler.cfg.predecessors ;
FROM: namespaces => set ;
IN: compiler.cfg.liveness.ssa

! TODO: merge with compiler.cfg.liveness

! Assoc mapping basic blocks to sequences of sets of vregs; each sequence
! is in correspondence with a predecessor
SYMBOL: edge-live-ins

: edge-live-in ( predecessor basic-block -- set ) edge-live-ins get at at ;

SYMBOL: work-list

: add-to-work-list ( basic-blocks -- )
    work-list get '[ _ push-front ] each ;

: compute-live-in ( basic-block -- live-in )
    [ live-out ] keep instructions>> transfer-liveness ;

: compute-edge-live-in ( basic-block -- edge-live-in )
    H{ } clone [
        '[ inputs>> [ swap _ conjoin-at ] assoc-each ] each-phi
    ] keep ;

: update-live-in ( basic-block -- changed? )
    [ [ compute-live-in ] keep live-ins get maybe-set-at ]
    [ [ compute-edge-live-in ] keep edge-live-ins get maybe-set-at ]
    bi or ;

: compute-live-out ( basic-block -- live-out )
    [ successors>> [ live-in ] map ]
    [ dup successors>> [ edge-live-in ] with map ] bi
    append assoc-combine ;

: update-live-out ( basic-block -- changed? )
    [ compute-live-out ] keep
    live-outs get maybe-set-at ;

: liveness-step ( basic-block -- )
    dup update-live-out [
        dup update-live-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-ssa-live-sets ( cfg -- )
    needs-predecessors

    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone edge-live-ins set
    H{ } clone live-outs set
    post-order add-to-work-list
    work-list get [ liveness-step ] slurp-deque ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
