! Recompile and execute the actual C ABI callback fixture with all policies.
USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.checker compiler.cfg.value-numbering
compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.linear-scan.allocation.state io kernel namespaces parser
prettyprint sequences system tools.test compiler.units vocabs ;
IN: allocator.callback.matrix

t check-allocation? set-global
t check-ssa? set-global
f restartable-tests? set-global
t backtracking-loop-spills? set-global
value-flow-verifier-enabled? t assert=
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    dup register-allocator set-global
    "callback allocator=" write .
    { f t } [
        dup global-value-numbering? set-global
        "callback GVN=" write .
    { f t } [
        dup rematerialize-constants? set-global
        "callback rematerialization=" write .
        "resource:basis/compiler/tests/alien-large-return.factor" run-file
        "compiler.tests.alien-large-return" vocab-words compile
        "reference/compiler-flags-safety-20260909/callback-execute.factor" run-file
        test-failures get empty? t assert=
    ] each
] each
] each
"CALLBACK-MATRIX-COMPLETE: 16 configurations" print
test-failures get dup . empty? [ 0 ] [ 1 ] if exit
