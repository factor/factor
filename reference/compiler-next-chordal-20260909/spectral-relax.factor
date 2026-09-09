USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs benchmark.spectral-norm compiler.cfg
compiler.cfg.checker compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linearization
compiler.cfg.loop-detection compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.ssa
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.verifier
compiler.cfg.value-numbering compiler.cfg.utilities compiler.cfg.rpo sets io kernel locals math namespaces prettyprint sequences system words ;
IN: compiler.cfg.register-allocation.chordal
:: weighted-color-score ( vertex color affinities colors -- score )
    vertex affinities at >alist [| pair |
        pair first colors at color = pair second 0 ?
    ] map-sum ;
:: relax-weighted-colors ( graph order affinities colors -- )
    0 :> changed!
    order <reversed> [| vertex |
        vertex graph at [ colors at ] map :> occupied
        vertex colors at :> current
        current :> best!
        vertex current affinities colors weighted-color-score :> score!
        vertex affinities at keys [ colors at ] map members [| candidate |
            candidate occupied member? [ ] [
                vertex candidate affinities colors weighted-color-score :> gain
                gain score > [ candidate best! gain score! ] when
            ] if
        ] each
        best current = [ ] [ changed 1 + changed! best vertex colors set-at ] if
    ] each
    "RELAXED VERTICES " write changed . ;
SYMBOL: initial-preference-colors
<< \ preference-guided-colors def>> \ initial-preference-colors set-global >>
:: preference-guided-colors ( graph order affinities available -- colors )
    graph order affinities available initial-preference-colors get
        call( graph order affinities available -- colors ) :> colors
    graph order affinities colors relax-weighted-colors
    colors ;
SYMBOL: original-certified-colors
<< \ assign-certified-colors def>> \ original-certified-colors set-global >>
:: assign-certified-colors ( intervals cfg available -- )
    intervals cfg available original-certified-colors get
        call( intervals cfg available -- )
    "interference-graph" chordal-statistics get at :> graph
    graph-colors get :> colors
    cfg graph weighted-ssa-affinities :> preferences
    cfg needs-loops
    cfg [| bb |
        bb loop-nesting-at 0 > [
            bb instructions>> [| insn |
                insn ##phi? [
                insn dst>> graph key? [
                    insn inputs>> values [| source |
                        source graph key? [
                            insn dst>> :> dst
                            dst colors at :> current
                            source colors at :> candidate
                            current candidate = [ ] [
                                dst graph at [ colors at candidate = ] any? :> blocked
                                dst preferences at >alist [| pair |
                                    pair first2 :> ( partner weight )
                                    partner colors at :> color
                                    color candidate = weight 0 ?
                                    color current = weight 0 ? -
                                ] map-sum :> gain
                                "PHI-MISS " write
                                bb number>> bb loop-nesting-at 2array
                                dst source 2array current candidate 2array
                                blocked gain 2array 4array .
                            ] if
                        ] when
                    ] each
                ] when
                ] when
            ] each
        ] when
    ] each-basic-block ;
IN: compiler.cfg.register-allocation.ssa
SYMBOL: original-resolution
<< \ resolve-ssa-data-flow def>> \ original-resolution set-global >>
:: resolve-ssa-data-flow ( cfg -- )
    cfg original-resolution get call( cfg -- )
    "FINAL-CFG" print
    cfg linearization-order [| bb |
        "BLOCK " write bb number>> .
        bb instructions>> [ . ] each
    ] each ;
IN: compiler-next.chordal.spectral
chordal-allocator register-allocator set-global
t chordal-witness? set-global
f global-value-numbering? set-global
t check-allocation? set-global
t check-ssa? set-global
t rematerialize-constants? set-global
value-flow-verifier-enabled? t assert=
\ benchmark.spectral-norm:spectral-norm measure-compilation .
0 exit
