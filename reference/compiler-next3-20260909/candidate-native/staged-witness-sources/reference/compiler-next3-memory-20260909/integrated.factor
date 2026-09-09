USING: vocabs.refresh ;
<< refresh-all >>
USING: parser ;
USING: accessors arrays assocs compiler compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.loop-optimization
compiler.cfg.memory-optimization compiler.cfg.memory-optimization.validation
compiler.cfg.optimizer compiler.cfg.register-allocation
compiler.cfg.register-allocation.verifier compiler.cfg.representations.selection
compiler.cfg.slp compiler.units io kernel locals math namespaces
prettyprint sequences system tools.test words ;
<<
"/Users/erg/factor.worktrees/compiler-next3-memory/basis/compiler/cfg/memory-optimization/memory-optimization.factor" run-file
"/Users/erg/factor.worktrees/compiler-next3-memory/basis/compiler/cfg/memory-optimization/validation/validation.factor" run-file
>>
IN: compiler.cfg.memory-optimization
SYMBOL: audit-original-memory
SYMBOL: audit-memory-counts
<< \ optimize-memory def>> \ audit-original-memory set-global >>
! Observe the actual installed stage; do not replace the optimizer pipeline.
: optimize-memory ( cfg -- )
    audit-original-memory get call( cfg -- )
    memory-optimization? get [
        "cfgs" audit-memory-counts get inc-at
        memory-optimization-statistics get "eliminated-loads" of
        "eliminated" audit-memory-counts get [ 0 or + ] change-at
    ] when ;
IN: compiler.cfg.memory-optimization.validation
H{ { "cfgs" 0 } { "eliminated" 0 } } clone audit-memory-counts set-global
f memory-optimization? set-global
f loop-optimization? set-global f automatic-slp? set-global
f conversion-aware-representation-costs? set-global
t check-ssa? set-global t check-allocation? set-global
linear-scan-allocator register-allocator set-global
value-flow-verifier-enabled? t assert=
f restartable-tests? set-global f silent-tests? set-global
"/Users/erg/factor.worktrees/compiler-next3-memory/basis/compiler/cfg/memory-optimization/memory-optimization-tests.factor" run-file
"/Users/erg/factor.worktrees/compiler-next3-memory/basis/compiler/cfg/memory-optimization/validation/validation-tests.factor" run-file
test-failures get empty? t assert=
[ [let
    { f t } [| enabled? |
        enabled? memory-optimization? set
        H{ { "cfgs" 0 } { "eliminated" 0 } } clone audit-memory-counts set
        \ memory-loop-work "typed-word" word-prop 1array compile
        { memory-loop-work } compile
        { -19 0 7 38 } [| seed |
            { 0 1 2 3 7 17 100003 } [| n |
                seed <memory-cell> n memory-loop-work
                seed n memory-loop-answer assert=
            ] each
        ] each
        enabled? . audit-memory-counts get .
        enabled? [ audit-memory-counts get "eliminated" of 0 > t assert= ] when
    ] each
] ] with-scope
"MEMORY INTEGRATED PIPELINE PASS" print
0 exit
