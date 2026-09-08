! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.linearization
compiler.cfg.liveness compiler.cfg.predecessors
compiler.cfg.parallel-copy
compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal.bases
compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities compiler.utilities
cpu.architecture heaps kernel locals make math namespaces sequences
sets sorting ;
IN: compiler.cfg.register-allocation.chordal

SINGLETON: chordal-allocator

! MCS selects the reverse of a perfect elimination order on a chordal
! graph. Keep the certificate explicit: machine operand constraints can
! add interference beyond the ideal strict-SSA graph.
:: maximum-cardinality-order ( graph -- order )
    H{ } clone :> weights
    H{ } clone :> selected
    <max-heap> :> pending
    V{ } clone :> order
    graph keys [| vertex | vertex 0 vertex neg 2array pending heap-push ] each
    [ order length graph assoc-size < ] [
        pending heap-pop drop :> best
        best selected key? [ ] [
            best selected conjoin
            best order push
            best graph at [| neighbor |
                neighbor selected key? [ ] [
                    neighbor weights inc-at
                    neighbor neighbor weights at neighbor neg 2array pending heap-push
                ] if
            ] each
        ] if
    ] while
    order ;

:: earlier-neighbors ( vertex graph seen -- neighbors )
    vertex graph at [ seen key? ] filter ;

:: clique? ( vertices graph -- ? )
    vertices [| a |
        vertices [| b | a b = b a graph at member? or ] all?
    ] all? ;

:: perfect-order? ( graph order -- ? )
    H{ } clone :> seen
    graph [ [ dup ] H{ } map>assoc ] assoc-map :> neighbors
    0 :> index!
    order [| vertex |
        vertex graph seen earlier-neighbors :> earlier
        earlier empty? [ t ] [
            earlier [ seen at ] sort-by last :> parent
            earlier [| neighbor |
                neighbor parent = neighbor parent neighbors at key? or
            ] all?
        ] if
        index vertex seen set-at
        index 1 + index!
    ] all? ;

:: greedy-colors ( graph order -- colors )
    H{ } clone :> colors
    order [| vertex |
        vertex graph at [ colors at ] map sift :> used
        0 :> color!
        [ color used member? ] [ color 1 + color! ] while
        color vertex colors set-at
    ] each
    colors ;

:: affinity-colors ( graph order affinities -- colors )
    H{ } clone :> colors
    order [| vertex |
        vertex graph at [ colors at ] map sift :> used
        vertex affinities at [ colors at ] map sift
        [ used member? not ] find nip :> preferred
        0 :> color!
        [ color used member? ] [ color 1 + color! ] while
        preferred color or vertex colors set-at
    ] each
    colors ;

:: add-affinity ( source destination affinities -- )
    source destination = [
        source rep-of reg-class-of destination rep-of reg-class-of = [
            source destination affinities push-at
            destination source affinities push-at
        ] when
    ] unless ;

:: cfg-affinities ( cfg -- affinities )
    H{ } clone :> affinities
    cfg cfg>insns [| insn |
        insn ##phi? [
            insn inputs>> values [ insn dst>> affinities add-affinity ] each
        ] [
            insn ##copy? insn ##tagged>integer? or [
                insn src>> insn dst>> affinities add-affinity
            ] when
        ] if
    ] each
    affinities ;

:: interference-graph ( intervals -- graph )
    intervals [ vreg>> V{ } clone ] H{ } map>assoc :> graph
    intervals [ live-interval-start ] sort-by :> ordered
    ordered [| a i |
        ordered i 1 + tail-slice :> later
        later [ live-interval-start a live-interval-end > ] find drop
        later length or later swap head-slice [| b |
            a interval-reg-class b interval-reg-class = [
                a b intervals-intersect? [
                    b vreg>> a vreg>> graph at push
                    a vreg>> b vreg>> graph at push
                ] when
            ] when
        ] each
    ] each-index
    graph ;

SYMBOLS: graph-colors chordal-statistics phi-locations phi-entry-positions
    scratch-spills ;

:: color-ssa-intervals ( intervals cfg -- )
    intervals interference-graph :> graph
    graph maximum-cardinality-order :> order
    graph order cfg cfg-affinities affinity-colors graph-colors namespaces:set
    graph assoc-size :> vertices
    graph values [ length ] map-sum 2 / :> edges
    graph order perfect-order? :> chordal?
    H{
        { "vertices" vertices } { "edges" edges } { "chordal?" chordal? }
        { "color-assignments" 0 } { "repair-assignments" 0 }
    }
    chordal-statistics namespaces:set ;

! Phi operands live on their incoming edges, and all phi results are
! defined simultaneously at block entry. The normal liveness pass already
! supplies the edge uses. No SSA destruction or graph coalescing occurs.
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

:: preferred-register ( interval -- reg/f )
    interval vreg>> graph-colors get at :> color
    interval interval-reg-class registers get at :> available
    color [ color available length < [ color available nth ] [ f ] if ] [ f ] if ;

:: preferred-free? ( interval reg -- ? )
    interval active-intervals-for interval inactive-intervals-for append
    [| other | other reg>> reg = interval other intervals-intersect? and ] any? not ;

:: color-interval ( interval -- )
    interval live-interval-start [ deactivate-intervals ] [ activate-intervals ] bi
    interval preferred-register :> preferred
    preferred [ interval preferred preferred-free? ] [ f ] if [
        "color-assignments" chordal-statistics get inc-at
        interval preferred >>reg add-active
    ] [
        ! Excess colors and fragments displaced by spills are repaired
        ! using the common next-use splitting policy. The graph supplies
        ! stable physical choices for all other intervals and fragments.
        "repair-assignments" chordal-statistics get inc-at
        interval registers get assign-register
    ] if ;

:: allocate-colored-intervals ( intervals registers -- allocated )
    intervals registers init-allocator
    ! An SSA use can precede its definition in linearization order. A
    ! clobber-only fragment then disappears at a sync point without an
    ! earlier local definition to allocate its slot. Reserve ABI operand
    ! slots now; edge resolution supplies their values.
    intervals [ live-interval-state? ] filter [| interval |
        interval uses>> [| use |
            use spill-slot?>>
            use n>> interval vreg>> phi-entry-positions get at = not and
        ] filter [| use |
            interval vreg>> use use-rep>> use def-rep>> or
            assign-spill-slot drop
        ] each
    ] each
    unhandled-min-heap get [
        drop dup sync-point? [ handle ] [ color-interval ] if
    ] slurp-heap
    gather-intervals ;

: phi-vreg>location ( vreg -- reg/slot )
    dup pending-interval-assoc get at
    [ nip ] [ dup rep-of assign-spill-slot ] if* ;

:: record-phi-locations ( bb -- )
    bb instructions>> [ ##phi? ] filter [| phi |
        phi dst>> phi-vreg>location phi inputs>> phi dst>> rep-of 3array
    ] map bb phi-locations get set-at ;

:: assign-ssa-block ( bb -- )
    bb basic-block namespaces:set
    bb block-from unhandled-intervals get activate-new-intervals
    bb compiler.cfg.linear-scan.assignment:compute-live-in
    bb record-phi-locations
    bb [ [
        [
            dup insn#>> prepare-insn
            dup ##phi? [ drop ] [
                [ assign-all-registers ] [ emit-insn ] bi
            ] if
        ] each
    ] V{ } make ] change-instructions compiler.cfg.linear-scan.assignment:compute-live-out ;

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

:: chordal-allocation ( cfg -- )
    f leader-map namespaces:set
    cfg construct-ssa-bases
    cfg compute-ssa-live-sets
    representations get keys [ dup ] H{ } map>assoc leader-map namespaces:set
    cfg number-instructions
    cfg compute-ssa-intervals :> intervals
    intervals [ live-interval-state? ] filter cfg color-ssa-intervals
    check-allocation? get [ intervals required-register-uses ] [ f ] if :> expected
    cfg admissible-registers :> available
    intervals available allocate-colored-intervals :> allocated
    check-allocation? get [
        allocated available check-allocated-intervals
        allocated expected check-register-uses
    ] when
    cfg allocated assign-ssa-registers
    cfg resolve-ssa-data-flow
    cfg check-numbering ;

M: chordal-allocator allocate-cfg drop chordal-allocation ;

M: chordal-allocator allocator-statistics drop chordal-statistics get clone ;
