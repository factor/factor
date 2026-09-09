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
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.ssa
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

SYMBOLS: graph-colors chordal-statistics ;

:: affinity-misses ( affinities colors -- n )
    affinities >alist [| pair |
        pair first colors at :> color
        pair second [ colors at color = not ] count
    ] map-sum 2 / ;

:: color-ssa-intervals ( intervals cfg -- )
    intervals interference-graph :> graph
    graph maximum-cardinality-order :> order
    cfg cfg-affinities :> affinities
    graph order affinities affinity-colors :> colors
    affinities colors affinity-misses :> before
    graph order affinities colors improve-affinity-colors
    graph order affinities colors exchange-affinity-colors
    colors graph-colors namespaces:set
    graph assoc-size :> vertices
    graph values [ length ] map-sum 2 / :> edges
    graph order perfect-order? :> chordal?
    affinities colors affinity-misses :> after
    leader-map get keys [ dup leader = not ] count :> aliases
    H{
        { "vertices" vertices } { "edges" edges } { "chordal?" chordal? }
        { "color-assignments" 0 } { "repair-assignments" 0 }
        { "affinity-misses-before" before }
        { "affinity-misses-after" after }
        { "copy-aliases" aliases }
    }
    chordal-statistics namespaces:set ;

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
    cfg copy-leaders
    cfg number-instructions
    cfg compute-ssa-intervals :> intervals
    intervals [ live-interval-state? ] filter cfg color-ssa-intervals
    check-allocation? get [ intervals required-register-uses ] [ f ] if :> expected
    intervals available allocate-colored-intervals :> allocated
    check-allocation? get [
        allocated available check-allocated-intervals
        allocated expected check-register-uses
    ] when
    cfg allocated assign-ssa-registers
    cfg resolve-ssa-data-flow
    cfg check-numbering ;

: chordal-allocation ( cfg -- )
    dup admissible-registers chordal-allocation-with-registers ;

M: chordal-allocator allocate-cfg drop chordal-allocation ;

M: chordal-allocator allocator-statistics drop chordal-statistics get clone ;
