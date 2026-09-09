USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs arrays classes compiler.cfg compiler.cfg.checker
compiler.cfg.def-use compiler.cfg.linear-scan.allocation.state compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.metrics compiler.test compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.verifier compiler.cfg.register-allocation.rematerialization
compiler.cfg.value-numbering io kernel locals namespaces parser prettyprint sequences
system words ;
IN: compiler.cfg.register-allocation.chordal.spilling
SYMBOL: original-source-spiller
<< \ spill-ssa def>> \ original-source-spiller set-global >>
:: spill-ssa ( cfg bank -- fixed statistics )
    cfg bank original-source-spiller get call( cfg bank -- fixed statistics )
    :> ( fixed statistics )
    "SOURCE SPILL PLANS" print
    spill-plans get values [| plan |
        "BLOCK" print plan bb>> number>> .
        "ENTRY VERSIONS" print plan entry-versions>> .
        "SAVED ENTRY" print plan saved-entry>> keys .
        "EXIT VERSIONS" print plan exit-versions>> .
        "SAVED EXIT" print plan saved-exit>> keys .
    ] each
    "SOURCE INSTRUCTIONS" print
    cfg linearization-order [| bb |
        "BLOCK" print bb number>> .
        bb instructions>> [
            dup ##phi? [ [ dst>> ] [ inputs>> values ] bi 2array . ] [ . ] if
        ] each
    ] each
    fixed statistics ;

IN: allocator.chordal.tuning
f global-value-numbering? set-global
t check-allocation? set-global
t check-ssa? set-global
t rematerialize-constants? set-global
<< "reference/allocator-tuning-chordal-20260909/branch-pressure.factor" run-file >>
{ linear-scan-allocator chordal-allocator } [
    dup register-allocator set-global "ALLOCATOR" print .
    "METRICS" print
    \ branch-pressure measure-compilation .
    "EXECUTED" print
    0.0 \ branch-pressure def>> compile-call 3672.0 assert=
    17.0 \ branch-pressure def>> compile-call 16712.0 assert=
] each
0 exit
