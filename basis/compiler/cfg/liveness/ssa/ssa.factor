! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces deques accessors sets sequences assocs fry
hashtables dlists compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.rpo compiler.cfg.liveness ;
IN: compiler.cfg.liveness.ssa

! TODO: merge with compiler.cfg.liveness

! Assoc mapping basic blocks to sequences of sets of vregs; each sequence
! is in conrrespondence with a predecessor
SYMBOL: phi-live-ins

: phi-live-in ( predecessor basic-block -- set ) phi-live-ins get at at ;

SYMBOL: work-list

: add-to-work-list ( basic-blocks -- )
    work-list get '[ _ push-front ] each ;

: compute-live-in ( basic-block -- live-in )
    [ live-out ] keep instructions>> transfer-liveness ;

: compute-phi-live-in ( basic-block -- phi-live-in )
    instructions>> [ ##phi? ] filter [ f ] [
        H{ } clone [
            '[ inputs>> [ swap _ conjoin-at ] assoc-each ] each
        ] keep
    ] if-empty ;

: update-live-in ( basic-block -- changed? )
    [ [ compute-live-in ] keep live-ins get maybe-set-at ]
    [ [ compute-phi-live-in ] keep phi-live-ins get maybe-set-at ]
    bi and ; 

: compute-live-out ( basic-block -- live-out )
    [ successors>> [ live-in ] map ]
    [ dup successors>> [ phi-live-in ] with map ] bi
    append assoc-combine ;

: update-live-out ( basic-block -- changed? )
    [ compute-live-out ] keep
    live-outs get maybe-set-at ;

: liveness-step ( basic-block -- )
    dup update-live-out [
        dup update-live-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-ssa-live-sets ( cfg -- cfg' )
    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone phi-live-ins set
    H{ } clone live-outs set
    dup post-order add-to-work-list
    work-list get [ liveness-step ] slurp-deque ;
