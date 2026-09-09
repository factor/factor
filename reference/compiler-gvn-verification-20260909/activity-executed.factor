USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors allocator-runtime-comparison arrays assocs
benchmark.spectral-norm benchmark.nbody benchmark.struct-arrays compiler.cfg compiler.cfg.checker compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.metrics compiler.cfg.linearization
compiler.cfg.register-allocation compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.utilities
compiler.cfg.value-numbering compiler.cfg.value-numbering.global
io json kernel locals math namespaces parser sequences system words ;
IN: compiler.cfg.value-numbering.global
SYMBOL: activity-original-global
SYMBOL: activity-counts
<< \ global-value-numbering def>> \ activity-original-global set-global >>
:: global-value-numbering ( graph -- changed? )
    graph cfg>insns [ ##copy? ] count :> before
    graph activity-original-global get call( cfg -- changed? ) :> changed?
    activity-counts get [| counts |
        "calls" counts inc-at
        changed? [ "changed-cfgs" counts inc-at ] when
        graph cfg>insns [ ##copy? ] count before -
        "expressions-eliminated" counts [ 0 or + ] change-at
    ] when*
    changed? ;
IN: compiler.cfg.value-numbering.global.validation.activity
[ [let
    t check-ssa? set t check-allocation? set
    linear-scan-allocator register-allocator set
    value-flow-verifier-enabled? t assert=
    { branch-pressure integer-pressure spectral-norm benchmark.nbody:nbody benchmark.struct-arrays:struct-arrays-bench }
    \ spectral-norm "typed-word" word-prop suffix :> targets
    { f t } [| enabled? |
        enabled? global-value-numbering? set
        { f t } [| remat? |
            remat? rematerialize-constants? set
            targets [| target |
                H{ { "calls" 0 } { "changed-cfgs" 0 } { "expressions-eliminated" 0 } } clone :> counts
                counts activity-counts set
                target measure-compilation drop
                enabled? [ counts "calls" of 0 > t assert= ]
                [ counts "calls" of 0 assert= ] if
                target name>> "target" counts set-at
                enabled? "gvn" counts set-at
                remat? "rematerialization" counts set-at
                counts >json print flush
            ] each
        ] each
    ] each
] ] with-scope
"GVN BENCHMARK ACTIVITY PASS" print
0 exit
