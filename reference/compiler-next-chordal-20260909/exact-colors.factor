USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.chordal.spilling.next-use
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.ssa.phases
compiler.cfg.value-numbering io kernel locals math namespaces parser prettyprint sequences system words ;
<< "reference/allocator-speed-crossarch-20260908/workloads.factor" run-file
   "reference/allocator-speed-crossarch-20260908/pressure.factor" run-file >>
USE: allocator-runtime-comparison
IN: compiler.cfg.register-allocation.chordal
USING: arrays sets sorting compiler.cfg.registers cpu.architecture ;
:: sorted-color-oracle ( graph order affinities available -- colors )
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
        free [| color |
            color vertex preferences at at 0 or
            color shared at 0 or + neg color 2array
        ] sort-by first :> chosen
        chosen vertex colors set-at
        chosen shared inc-at
        vertex affinities at [| partner weight |
            chosen partner preferences at [ 0 or weight 8 * + ] change-at
        ] assoc-each
    ] each
    colors ;

SYMBOL: actual-coloring
<< \ preference-guided-colors def>> \ actual-coloring set-global >>
SYMBOL: compared-graphs
:: preference-guided-colors ( graph order affinities available -- colors )
    graph order affinities available actual-coloring get
        call( graph order affinities available -- colors ) :> colors
    graph order affinities available sorted-color-oracle colors assert=
    1 compared-graphs get push
    colors ;
IN: compiler-next.chordal.profile
USING: compiler.cfg.register-allocation.verifier tools.test ;
chordal-allocator register-allocator set-global
f global-value-numbering? set-global
t check-allocation? set-global
t check-ssa? set-global
t rematerialize-constants? set-global
value-flow-verifier-enabled? t assert=
V{ } clone compiler.cfg.register-allocation.chordal:compared-graphs set-global
allocator-runtime-comparison:metric-workloads [ measure-compilation drop ] each
"EXACT COLOR GRAPH COMPARISONS " write
compiler.cfg.register-allocation.chordal:compared-graphs get length dup 0 > t assert= .
"EXACT-COLOR-CORPUS PASS" print
f restartable-tests? set-global
"compiler.cfg.register-allocation.chordal" test
test-failures get empty? t assert=
"CHORDAL-GATE PASS" print
0 exit
