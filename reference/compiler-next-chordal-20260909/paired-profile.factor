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
IN: compiler-next.chordal.profile
SYMBOL: phase-times
:: record-phase-time ( start name -- )
    phase-times get [ nano-count start - :> elapsed name phase-times get [ 0 or elapsed + ] change-at ] when ;
USE: compiler-next.chordal.profile
IN: compiler.cfg.register-allocation.chordal.spilling.next-use
SYMBOL: saved-phase-0
<< \ compute-next-uses def>> \ saved-phase-0 set-global >>
:: compute-next-uses ( cfg -- entries exits )
    nano-count :> start
    cfg saved-phase-0 get call( cfg -- entries exits )
    start "compute-next-uses" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal.spilling.next-use
SYMBOL: saved-phase-1
<< \ instruction-next-uses def>> \ saved-phase-1 set-global >>
:: instruction-next-uses ( bb after -- afters )
    nano-count :> start
    bb after saved-phase-1 get call( bb after -- afters )
    start "instruction-next-uses" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal.spilling
SYMBOL: saved-phase-2
<< \ spill-ssa def>> \ saved-phase-2 set-global >>
:: spill-ssa ( cfg bank -- fixed statistics )
    nano-count :> start
    cfg bank saved-phase-2 get call( cfg bank -- fixed statistics )
    start "spill-ssa" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal
SYMBOL: saved-phase-3
<< \ interference-graph def>> \ saved-phase-3 set-global >>
:: interference-graph ( intervals -- graph )
    nano-count :> start
    intervals saved-phase-3 get call( intervals -- graph )
    start "interference-graph" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal
SYMBOL: saved-phase-4
<< \ maximum-cardinality-order def>> \ saved-phase-4 set-global >>
:: maximum-cardinality-order ( graph -- order )
    nano-count :> start
    graph saved-phase-4 get call( graph -- order )
    start "maximum-cardinality-order" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal
SYMBOL: saved-phase-5
<< \ perfect-order? def>> \ saved-phase-5 set-global >>
:: perfect-order? ( graph order -- ? )
    nano-count :> start
    graph order saved-phase-5 get call( graph order -- ? )
    start "perfect-order?" compiler-next.chordal.profile:record-phase-time ;
IN: compiler.cfg.register-allocation.chordal
SYMBOL: saved-phase-6
<< \ preference-guided-colors def>> \ saved-phase-6 set-global >>
:: preference-guided-colors ( graph order affinities available -- colors )
    nano-count :> start
    graph order affinities available saved-phase-6 get call( graph order affinities available -- colors )
    start "preference-guided-colors" compiler-next.chordal.profile:record-phase-time ;
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

IN: compiler-next.chordal.profile
SYMBOL: scan-coloring
compiler.cfg.register-allocation.chordal:saved-phase-6 get scan-coloring set-global
chordal-allocator register-allocator set-global
f global-value-numbering? set-global
f check-allocation? set-global
f check-ssa? set-global
t rematerialize-constants? set-global
[let
{ f t t f } [| scan? |
    scan? [ scan-coloring get ] [ \ sorted-color-oracle def>> ] if
        compiler.cfg.register-allocation.chordal:saved-phase-6 set-global
    allocator-runtime-comparison:metric-workloads [| word |
        H{ } clone phase-times set-global
        nano-count :> start
        word measure-compilation :> report
        "SCAN " write scan? .
        "PROFILE " write word name>> .
        phase-times get .
        "TOTAL " write nano-count start - .
        "CODE " write "procedures" report at [ "code-bytes" swap at ] map . flush
    ] each
] each
]
0 exit
