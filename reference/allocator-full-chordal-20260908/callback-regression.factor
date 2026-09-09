! Recompile the real C ABI fixture under each recipe setting, including
! the compacting-GC and nested-callback hidden result address tests.
USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier io kernel namespaces parser
prettyprint sequences system tools.test ;
IN: chordal.callback.regression

t check-allocation? set-global
chordal-allocator register-allocator set-global
{ f t } [
    dup rematerialize-constants? set-global
    "callback rematerialization=" write .
    "resource:basis/compiler/tests/alien-large-return.factor" run-file
] each
"compiler.cfg.register-allocation.chordal.spilling" test
test-failures get dup . empty? [ 0 ] [ 1 ] if exit
