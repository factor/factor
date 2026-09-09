USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs compiler.cfg.checker compiler.cfg.memory-optimization
compiler.cfg.memory-optimization.validation compiler.cfg.optimizer
compiler.cfg.register-allocation.verifier io kernel math namespaces parser
prettyprint sequences system tools.test words ;
IN: compiler.cfg.optimizer
SYMBOL: original-memory-audit-ssa
SYMBOL: memory-audit-counts
<< \ optimize-ssa def>> \ original-memory-audit-ssa set-global >>
: optimize-ssa ( cfg -- )
    dup original-memory-audit-ssa get call( cfg -- )
    dup optimize-memory check-ssa
    memory-optimization? get [
        "cfgs" memory-audit-counts get inc-at
        memory-optimization-statistics get "eliminated-loads" of
        "eliminated" memory-audit-counts get [ 0 or + ] change-at
    ] when ;
IN: compiler.cfg.memory-optimization.validation
H{ { "cfgs" 0 } { "eliminated" 0 } } clone memory-audit-counts set-global
f memory-optimization? set-global
f restartable-tests? set-global
f silent-tests? set-global
"resource:basis/compiler/cfg/memory-optimization/memory-optimization-tests.factor" run-file
"resource:basis/compiler/cfg/memory-optimization/validation/validation-tests.factor" run-file
test-failures get empty? t assert=
memory-audit-counts get .
memory-audit-counts get "eliminated" of 0 > t assert=
"MEMORY NATIVE PASS" print
0 exit
