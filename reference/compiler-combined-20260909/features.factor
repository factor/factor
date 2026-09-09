! Shared configuration and witness registry. No compiler instrumentation.
USING: accessors allocator-runtime-comparison arrays assocs kernel locals
namespaces sequences vocabs words ;
IN: compiler-next3.benchmark
CONSTANT: feature-options H{
    { "loops" { "compiler.cfg.loop-optimization" "loop-optimization?" } }
    { "representations" { "compiler.cfg.representations.selection" "conversion-aware-representation-costs?" } }
    { "memory" { "compiler.cfg.memory-optimization" "memory-optimization?" } }
    { "slp" { "compiler.cfg.slp" "automatic-slp?" } }
}
SYMBOL: feature-witnesses
H{ } clone feature-witnesses set-global
:: register-witness ( feature work target iterations -- )
    H{ { "work" work } { "target" target } { "iterations" iterations } }
    feature feature-witnesses get-global set-at ;
:: configure-features ( selected enabled? -- options )
    selected "all" assert=
    H{ } clone :> options
    feature-options [| feature pair |
        pair first2 swap lookup-word :> flag
        flag f eq? f assert=
        enabled? :> requested
        requested flag namespaces:set
        flag get requested assert=
        flag get feature options set-at
    ] assoc-each
    options ;
:: selected-witness ( feature -- witness )
    feature feature-witnesses get-global at dup f eq? f assert= ;
CONSTANT: feature-order { "loops" "representations" "memory" "slp" }
: all-witnesses ( -- witnesses )
    feature-order [ selected-witness ] map ;
: benchmark-runtime-workloads ( -- words )
    workloads all-witnesses [ "work" swap at ] map append ;
: benchmark-metric-workloads ( -- words )
    metric-workloads all-witnesses [ "target" swap at ] map append ;
:: witness-batch-count ( word -- n )
    all-witnesses [ "work" swap at word eq? ] filter
    dup length 1 assert= first "iterations" swap at ;
: all-witness-roots ( -- words )
    all-witnesses [ [ "work" swap at ] [ "target" swap at ] bi 2array ] map concat ;
: prepare-selected-closure ( -- )
    workloads all-witness-roots append benchmark-closure benchmark-words set-global ;

: reset-features-global ( -- )
    feature-options values [
        first2 swap lookup-word dup f eq? f assert=
        f swap set-global
    ] each ;
:: global-feature-options ( -- options )
    H{ } clone :> options
    feature-options [| feature pair |
        pair first2 swap lookup-word get-global feature options set-at
    ] assoc-each
    options ;
