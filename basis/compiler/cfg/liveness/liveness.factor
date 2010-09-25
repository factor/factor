! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs fry deques dlists namespaces
sequences sets compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.utilities compiler.cfg.predecessors
compiler.cfg.rpo cpu.architecture ;
FROM: namespaces => set ;
IN: compiler.cfg.liveness

! See http://en.wikipedia.org/wiki/Liveness_analysis

SYMBOL: live-ins

: live-in ( bb -- set )
    live-ins get at ;

SYMBOL: live-outs

: live-out ( bb -- set )
    live-outs get at ;

! Assoc mapping basic blocks to sequences of sets of vregs; each
! sequence is in correspondence with a predecessor
SYMBOL: edge-live-ins

: edge-live-in ( predecessor basic-block -- set )
    edge-live-ins get at at ;

GENERIC: visit-insn ( live-set insn -- live-set )

: kill-defs ( live-set insn -- live-set )
    defs-vregs [ over delete-at ] each ; inline

: gen-uses ( live-set insn -- live-set )
    uses-vregs [ over conjoin ] each ; inline

M: vreg-insn visit-insn [ kill-defs ] [ gen-uses ] bi ;

! Our liveness analysis annotates call sites with GC maps
! indicating the spill slots in the stack frame that contain
! tagged pointers, and thus have to be visited if a GC occurs
! inside the call.

: fill-gc-map ( live-set insn -- live-set )
    representations get [
        gc-map>> over keys
        [ rep-of tagged-rep? ] filter
        >>gc-roots
    ] when
    drop ;

M: gc-map-insn visit-insn
    [ kill-defs ] [ fill-gc-map ] [ gen-uses ] tri ;

M: ##phi visit-insn kill-defs ;

M: insn visit-insn drop ;

: transfer-liveness ( live-set instructions -- live-set' )
    [ clone ] [ <reversed> ] bi* [ visit-insn ] each ;

: local-live-in ( instructions -- live-set )
    [ H{ } ] dip transfer-liveness keys ;

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

: compute-live-sets ( cfg -- )
    needs-predecessors

    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone edge-live-ins set
    H{ } clone live-outs set
    post-order add-to-work-list
    work-list get [ liveness-step ] slurp-deque ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
