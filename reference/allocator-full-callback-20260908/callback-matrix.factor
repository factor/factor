! Recompile and execute the actual C ABI callback fixture with all policies.
USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: compiler.cfg.checker compiler.cfg.value-numbering
compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier io kernel namespaces parser
prettyprint sequences system tools.test ;
IN: allocator.callback.matrix

t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
t backtracking-loop-spills? set-global
value-flow-verifier-enabled? t assert=
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    dup register-allocator set-global
    "callback allocator=" write .
    { f t } [
        dup rematerialize-constants? set-global
        "callback rematerialization=" write .
        "resource:basis/compiler/tests/alien-large-return.factor" run-file
    ] each
] each
"compiler.cfg.register-allocation.backtracking" test
test-failures get dup . empty? [ 0 ] [ 1 ] if exit
