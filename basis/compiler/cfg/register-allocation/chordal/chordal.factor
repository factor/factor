! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.linearization
compiler.cfg.liveness compiler.cfg.predecessors
compiler.cfg.parallel-copy
compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.ssa
compiler.cfg.register-allocation.ssa.liveness
compiler.cfg.register-allocation.ssa.phases
compiler.cfg.loop-detection
compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities compiler.utilities
cpu.architecture heaps kernel locals make math math.functions math.order namespaces sequences
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
            earlier [ seen at ] maximum-by :> parent
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

:: affinity-score ( vertex color affinities colors -- score )
    vertex affinities at [ colors at color = ] count ;

! A later phi partner may not have a color when MCS first visits a value.
! Revisit affinities after coloring without changing any interference edge.
! Every accepted recoloring strictly reduces the number of unequal partners.
:: improve-affinity-colors ( graph order affinities colors -- )
    0 :> passes!
    t :> changed!
    [ changed passes 3 < and ] [
        f changed!
        passes 1 + passes!
        order <reversed> [| vertex |
            vertex graph at [ colors at ] map :> used
            vertex colors at :> current
            vertex current affinities colors affinity-score :> score!
            current :> best!
            vertex affinities at [ colors at ] map sift [| candidate |
                candidate used member? [ ] [
                    vertex candidate affinities colors affinity-score :> candidate-score
                    candidate-score score > [
                        candidate best! candidate-score score!
                    ] when
                ] if
            ] each
            best current = [ ] [ t changed! ] if
            best vertex colors set-at
        ] each
    ] while ;

:: two-color-component ( vertex first-color second-color graph colors -- component )
    H{ } clone :> component
    V{ vertex } clone :> pending
    [ pending empty? not ] [
        pending pop :> current
        current component key? [ ] [
            current component conjoin
            current graph at [| neighbor |
                neighbor colors at :> color
                color first-color = color second-color = or [
                    neighbor component key? [ ] [ neighbor pending push ] if
                ] when
            ] each
        ] if
    ] while
    component ;

:: exchanged-color ( color first-color second-color -- color' )
    color first-color = second-color first-color ? ;

:: exchange-benefit ( component first-color second-color affinities colors -- benefit )
    component keys [| vertex |
        vertex colors at :> before
        before first-color second-color exchanged-color :> after
        vertex affinities at [ component key? ] reject [| partner |
            partner colors at :> other
            after other = 1 0 ? before other = 1 0 ? -
        ] map-sum
    ] map-sum ;

! Swapping both colors in an entire connected component preserves every
! interference constraint. It can free a phi partner's color even when a
! single-vertex recoloring cannot. Accept only a strict net affinity gain.
:: exchange-affinity-colors ( graph order affinities colors -- )
    0 :> passes!
    t :> changed!
    [ changed passes 2 < and ] [
        f changed!
        passes 1 + passes!
        order [| vertex |
            vertex affinities at [| partner |
                vertex colors at :> first-color
                partner colors at :> second-color
                second-color [
                    first-color second-color = not
                    partner vertex graph at member? not and
                ] [ f ] if [
                    vertex first-color second-color graph colors two-color-component :> component
                    partner component key? [ ] [
                        component first-color second-color affinities colors exchange-benefit 0 > [
                            t changed!
                            component keys [| member |
                                member colors at first-color second-color exchanged-color
                                member colors set-at
                            ] each
                        ] when
                    ] if
                ] when
            ] each
        ] each
    ] while ;

:: add-affinity ( source-vreg destination-vreg affinities -- )
    source-vreg leader :> source
    destination-vreg leader :> destination
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

SYMBOLS: graph-colors chordal-statistics chordal-witness? ;

ERROR: non-chordal-spill-result graph order ;
ERROR: uncolorable-spill-result vertex neighbors capacity ;

:: add-weighted-affinity ( a b weight graph affinities -- )
    a b = a graph key? not or b graph key? not or [ ] [
        a rep-of reg-class-of b rep-of reg-class-of = [
            a affinities at b swap [ 0 or weight + ] change-at
            b affinities at a swap [ 0 or weight + ] change-at
        ] when
    ] if ;

:: weighted-ssa-affinities ( cfg graph -- affinities )
    graph keys [ H{ } clone ] H{ } map>assoc :> affinities
    cfg needs-loops
    cfg [| bb |
        8 bb loop-nesting-at 3 min ^ :> weight
        bb instructions>> [| insn |
            insn ##phi? [
                insn inputs>> values [| source |
                    insn dst>> source weight graph affinities add-weighted-affinity
                ] each
            ] [
                insn ##copy? insn ##tagged>integer? or [
                    insn dst>> insn src>> weight graph affinities add-weighted-affinity
                ] [
                    ! The portable first-input phase permits result reuse.
                    ! Favor it weakly: x86 two-operand emission can then omit
                    ! its preparatory copy, while explicit phi/copy choices
                    ! retain greater preference weight.
                    insn phase-split-insn? insn def-is-use-insn? not and
                    insn defs-vregs length 1 = and
                    insn uses-vregs empty? not and [
                        insn defs-vregs first insn uses-vregs first
                        weight 8 / graph affinities add-weighted-affinity
                    ] when
                ] if
            ] if
        ] each
    ] each-basic-block
    affinities ;

! Chunks share preferences, never interference representatives. Even when
! two members conflict, their graph edge remains present and authoritative.
:: affinity-chunks ( affinities -- chunks )
    H{ } clone :> chunks
    affinities keys [| root |
        root chunks key? [ ] [
            V{ root } clone :> pending
            V{ } clone :> chunk
            [ pending empty? not ] [
                pending pop :> vertex
                vertex chunks key? [ ] [
                    chunk vertex chunks set-at
                    vertex chunk push
                    vertex affinities at keys pending push-all
                ] if
            ] while
        ] if
    ] each
    chunks ;

! Free colors are in ascending bank order. A strict improvement retains the
! smallest color on ties, matching the previous [ -score, color ] ordering
! without sorting or allocating a comparison pair for every free color.
:: preferred-free-color ( free preferences shared -- color )
    free first :> best!
    best preferences at 0 or best shared at 0 or + :> score!
    free rest-slice [| color |
        color preferences at 0 or color shared at 0 or + :> candidate
        candidate score > [ color best! candidate score! ] when
    ] each
    best ;

:: preference-guided-colors ( graph order affinities available -- colors )
    H{ } clone :> colors
    graph keys [ H{ } clone ] H{ } map>assoc :> preferences
    affinities affinity-chunks :> chunks
    chunks values [ first ] map members
    [ H{ } clone ] H{ } map>assoc :> chunk-preferences
    order [| vertex |
        vertex chunks at first chunk-preferences at :> shared
        vertex graph at [ colors at ] map sift :> occupied
        vertex rep-of reg-class-of available at length :> capacity
        capacity <iota> [ occupied member? not ] filter :> free
        free empty? [ vertex occupied capacity uncolorable-spill-result ] when
        free vertex preferences at shared preferred-free-color :> chosen
        chosen vertex colors set-at
        chosen shared inc-at
        vertex affinities at [| partner weight |
            chosen partner preferences at [ 0 or weight 8 * + ] change-at
        ] assoc-each
    ] each
    colors ;

:: assign-certified-colors ( intervals cfg available -- )
    intervals interference-graph :> graph
    graph maximum-cardinality-order :> order
    graph order perfect-order? [ ] [ graph order non-chordal-spill-result ] if
    cfg graph weighted-ssa-affinities :> weighted
    graph order weighted available preference-guided-colors :> colors
    colors graph-colors namespaces:set
    intervals [| interval |
        interval vreg>> colors at
        interval interval-reg-class available at nth interval reg<<
    ] each
    "decoupled-ssa-chordal" "algorithm" chordal-statistics get set-at
    0 "fallback-count" chordal-statistics get set-at
    0 "repair-assignments" chordal-statistics get set-at
    intervals length "color-assignments" chordal-statistics get set-at
    t "post-spill-chordal?" chordal-statistics get set-at
    t "chordal?" chordal-statistics get set-at
    graph assoc-size "vertices" chordal-statistics get set-at
    graph values [ length ] map-sum 2 / "edges" chordal-statistics get set-at
    chordal-witness? get [
        order reverse "perfect-elimination-order" chordal-statistics get set-at
        colors "colors" chordal-statistics get set-at
        graph "interference-graph" chordal-statistics get set-at
    ] when ;

:: affinity-misses ( affinities colors -- n )
    affinities >alist [| pair |
        pair first colors at :> color
        pair second [ colors at color = not ] count
    ] map-sum 2 / ;

! Exact SSA copies denote the same value on every path dominated by the
! copy. Give their intervals one representative before coloring; phis retain
! their own definitions and are resolved only on their incoming edges. Do not
! merge representation changes: tagged and derived roots need distinct maps.
:: copy-leaders ( cfg -- )
    representations get keys [ dup ] H{ } map>assoc leader-map namespaces:set
    cfg cfg>insns [| insn |
        insn ##copy? [
            insn src>> rep-of insn dst>> rep-of = [
                insn src>> leader insn dst>> leader-map get set-at
            ] when
        ] when
    ] each ;

:: chordal-allocation-with-registers ( cfg available -- )
    f leader-map namespaces:set
    cfg construct-ssa-bases
    cfg compute-ssa-live-sets
    cfg available spill-ssa :> ( fixed statistics )
    statistics chordal-statistics namespaces:set
    representations get keys [ dup ] H{ } map>assoc leader-map namespaces:set
    available registers namespaces:set
    cfg compute-ssa-live-sets-preserving-gc
    ! Recipe discovery and its counters belong to source spilling. Number
    ! the rewritten instructions without replacing that provenance/state.
    cfg linearization-order
    0 [ instructions>> [ number-instruction ] each ] reduce drop
    chordal-witness? get [
        available [ length ] assoc-map "register-capacities" statistics set-at
        cfg cfg>insns [ ##spill? ] count "source-stores-before-color" statistics set-at
        cfg cfg>insns [ ##reload? ] count "source-reloads-before-color" statistics set-at
        fixed assoc-size "fixed-memory-values" statistics set-at
    ] when
    cfg fixed compute-phase-ssa-intervals-with-locations
    [ live-interval-state? ] filter :> intervals
    intervals cfg available assign-certified-colors
    check-allocation? get [
        intervals available check-allocated-intervals
    ] when
    cfg intervals fixed assign-phase-ssa-registers-with-locations
    cfg resolve-ssa-data-flow
    cfg check-numbering ;

: chordal-allocation ( cfg -- )
    dup admissible-registers chordal-allocation-with-registers ;

M: chordal-allocator allocate-cfg drop chordal-allocation ;

M: chordal-allocator allocator-statistics drop chordal-statistics get clone ;
