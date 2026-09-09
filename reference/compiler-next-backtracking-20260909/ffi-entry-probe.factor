USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: alien.libraries alien.c-types parser ;
<< "allocator-counters" "./reference/allocator-speed-crossarch-20260908/counters" cdecl add-library
"./reference/allocator-tuning-backtracking-20260909/ffi-fixture.factor" run-file >>
USING: accessors assocs compiler.cfg.metrics compiler.cfg.utilities compiler.cfg
compiler.cfg.linear-scan.allocation.state compiler.cfg.checker compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.value-numbering io kernel namespaces prettyprint prettyprint.config
sequences tools.annotations system json compiler.cfg.linearization
compiler.cfg.linear-scan.assignment compiler.cfg.register-allocation.ssa
compiler.cfg.instructions locals command-line ;
IN: allocator-runtime-comparison
f length-limit set 5 nesting-limit set
backtracking-allocator register-allocator set-global
t check-allocation? set-global t check-ssa? set-global
t rematerialize-constants? set-global t backtracking-loop-spills? set-global
f global-value-numbering? set-global
:: dump-edges ( graph -- )
    graph linearization-order [| bb |
        "BLOCK " write bb number>> .
        "SUCCESSORS " write bb successors>> [ number>> ] map .
        "LIVE-IN " write bb machine-live-ins get at .
        "LIVE-OUT " write bb machine-live-outs get at .
        bb instructions>> [ . ] each
    ] each ;

command-line get first "off" = [
    \ reify-entry-transports [ drop [ drop 0 backtracking-edge-entry-reloads set ] ] annotate
] when
\ backtracking-allocation-with-registers
[ [ cfg get cfg>insns [ . ] each ] append ] annotate
\ ffi-pressure measure-compilation >json print
ffi-pressure-work "NATIVE-ANSWER-PASS" print
0 exit
