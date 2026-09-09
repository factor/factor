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
USING: compiler compiler.units locals ;
H{ { "cfgs" 0 } { "eliminated" 0 } } clone memory-audit-counts set-global
t check-ssa? set-global t check-allocation? set-global
[ [let
    { f t } [| enabled? |
        enabled? memory-optimization? set
        H{ { "cfgs" 0 } { "eliminated" 0 } } clone memory-audit-counts set
        \ memory-loop-work "typed-word" word-prop 1array compile
        { memory-loop-work } compile
        { -19 0 7 38 } [| seed |
            { 0 1 2 3 7 17 100003 } [| n |
                seed <memory-cell> n memory-loop-work
                seed n memory-loop-answer assert=
            ] each
        ] each
        enabled? . memory-audit-counts get .
        enabled? [ memory-audit-counts get "eliminated" of 0 > t assert= ] when
    ] each
] ] with-scope
"MEMORY HOTLOOP NATIVE PASS" print
0 exit
