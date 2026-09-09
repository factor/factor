! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.resolve
compiler.cfg.linearization compiler.cfg.liveness compiler.cfg.parallel-copy
compiler.cfg.predecessors compiler.cfg.register-allocation.rematerialization
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities cpu.architecture kernel locals make namespaces
sequences sorting ;
IN: compiler.cfg.register-allocation.ssa

! SSA transport and interval mechanics only. Allocators supply all physical
! choices and spill decisions; these words never invoke an allocation policy.
SYMBOLS: phi-locations phi-entry-positions scratch-spills ;

! Phi operands live on their incoming edges, and all phi results are
! defined simultaneously at block entry. The normal liveness pass already
! supplies the edge uses. Exact copies share intervals; phis stay in SSA.
:: compute-ssa-intervals-in-block ( bb -- )
    bb block-from from namespaces:set
    bb block-to to namespaces:set
    bb handle-live-out
    bb instructions>> <reversed> [
        dup ##phi?
        [
            dst>> from get over phi-entry-positions get set-at
            from get t record-def
        ]
        [ compute-live-intervals* ] if
    ] each ;

: compute-ssa-intervals ( cfg -- intervals/sync-points )
    H{ } clone live-intervals namespaces:set
    H{ } clone phi-entry-positions namespaces:set
    [
        linearization-order <reversed> [ compute-ssa-intervals-in-block ] each
        live-intervals get values dup [ finish-live-interval ] each
    ] [ cfg>sync-points ] bi append ;

! A rematerialized constant has no initialized spill slot. Use its recipe
! at boundaries without resident fragments, just as shared assignment does.
: phi-vreg>location ( vreg -- reg/slot/recipe )
    leader dup pending-interval-assoc get at
    [ nip ] [
        dup rematerialization-of
        [ nip ] [ dup rep-of assign-spill-slot ] if*
    ] if* ;

! A value can cross a block with no local register use. Splitting may then
! leave no assigned fragment at that boundary, even if a later-layout SSA
! definition has not allocated a spill slot yet. Reserve an edge destination;
! parallel edge resolution supplies the value from each actual predecessor.
: ssa-live-locations ( live-set -- locations )
    [ phi-vreg>location ] assoc-map ;

: compute-ssa-live-in ( bb -- )
    [ live-in ssa-live-locations ] keep machine-live-ins get set-at ;

: compute-ssa-live-out ( bb -- )
    [ live-out ssa-live-locations ] keep machine-live-outs get set-at ;

:: record-phi-locations ( bb -- )
    bb instructions>> [ ##phi? ] filter [| phi |
        phi dst>> phi-vreg>location phi inputs>> phi dst>> rep-of 3array
    ] map bb phi-locations get set-at ;

:: assign-ssa-block ( bb -- )
    bb basic-block namespaces:set
    bb block-from unhandled-intervals get activate-new-intervals
    bb compute-ssa-live-in
    bb record-phi-locations
    bb [ [
        [
            dup insn#>> prepare-insn
            dup ##phi? [ drop ] [
                [ assign-all-registers ] [ emit-insn ] bi
            ] if
        ] each
    ] V{ } make ] change-instructions compute-ssa-live-out ;

:: assign-ssa-registers ( cfg intervals -- )
    intervals init-assignment
    H{ } clone phi-locations namespaces:set
    cfg linearization-order [ kill-block?>> ] reject
    [ assign-ssa-block ] each ;

:: ssa-edge-mappings ( bb to -- mappings )
    bb machine-live-out :> outgoing
    to machine-live-in :> incoming
    [
        incoming [| vreg destination |
            vreg outgoing at destination 2dup =
            [ 2drop ] [ vreg rep-of add-mapping ] if
        ] assoc-each
        to phi-locations get at [| phi |
            bb phi second at :> source
            source outgoing at phi first 2dup =
            [ 2drop ] [ phi third add-mapping ] if
        ] each
    ] { } make ;

:: scratch-representation ( reg-class -- rep )
    representations get values [ reg-class-of reg-class = ] filter
    [ rep-size ] sort-by last ;

:: memory>memory ( source destination -- )
    source rep>> :> rep
    rep reg-class-of :> reg-class
    reg-class registers get at first :> scratch
    reg-class scratch-representation :> saved-rep
    saved-rep scratch-spills get [
        rep-size cfg get stack-frame>>
        [ align-spill-area ] [ next-spill-slot ] 2bi
    ] cache :> slot
    scratch saved-rep slot ##spill,
    scratch rep source reg>> ##reload,
    scratch rep destination reg>> ##spill,
    scratch saved-rep slot ##reload, ;

: ssa>insn ( source destination -- )
    2dup [ reg>> spill-slot? ] both?
    [ memory>memory ] [ >insn ] if ;

: ssa-mapping-instructions ( mappings -- insns )
    [ swap ] H{ } assoc-map-as [
        [ temp-location ] [ swap ssa>insn ] parallel-mapping
        ##branch,
    ] { } make ;

: perform-ssa-mappings ( bb to mappings -- )
    [ 2drop ] [
        ssa-mapping-instructions insert-basic-block
        cfg get cfg-changed
    ] if-empty ;

:: resolve-ssa-block ( bb -- )
    bb kill-block?>> [
        bb successors>> clone [| to |
            bb to bb to ssa-edge-mappings perform-ssa-mappings
        ] each
    ] unless ;

: resolve-ssa-data-flow ( cfg -- )
    init-resolve
    H{ } clone scratch-spills namespaces:set
    [ needs-predecessors ] [ [ resolve-ssa-block ] each-basic-block ] bi ;

