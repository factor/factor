USING: parser vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh
"compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: tools.test namespaces sequences kernel ;
<< "compiler.cfg.register-allocation.rematerialization" test
test-failures get empty? [ ] [ "Native rematerialization tests failed" throw ] if >>
USING: assocs compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.rematerialization.tests
io json locals prettyprint ;
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
[| allocator |
    { f t } [| enabled? |
        allocator enabled? pressure-metrics :> metrics
        allocator unparse "allocator" metrics set-at
        enabled? "enabled" metrics set-at metrics >json print
    ] each
] each
