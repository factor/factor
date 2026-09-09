! Explicit experiment-only activation. Normal production source does not call
! recoloring. The body below matches baseline assign-certified-colors except
! the inserted improve-weighted-colors call and counter.
USING: accessors assocs compiler.cfg.linear-scan.live-intervals
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.chordal.recoloring
compiler.cfg.registers kernel locals math namespaces sequences ;
IN: compiler.cfg.register-allocation.chordal
SYMBOL: experimental-recolor-counts
V{ } clone experimental-recolor-counts set-global
:: assign-certified-colors ( intervals cfg available -- )
    intervals interference-graph :> graph
    graph maximum-cardinality-order :> order
    graph order perfect-order? [ ] [ graph order non-chordal-spill-result ] if
    cfg graph weighted-ssa-affinities :> weighted
    graph order weighted available preference-guided-colors :> colors
    graph order weighted available colors improve-weighted-colors
    dup experimental-recolor-counts get push
    "recolored-vertices" chordal-statistics get set-at
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

