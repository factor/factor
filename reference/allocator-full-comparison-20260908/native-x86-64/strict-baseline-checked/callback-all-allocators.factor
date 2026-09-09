USING: parser vocabs vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: compiler.cfg.linear-scan.allocation.state compiler.cfg.checker
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
io kernel namespaces prettyprint sequences system tools.test ;
IN: allocator-runtime-comparison
t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
t backtracking-loop-spills? set-global
{ "linear-scan" "greedy" "backtracking" "chordal" } [
    dup "CALLBACK ALLOCATOR " write print select-allocator
    register-allocator get register-allocator set-global
    { f t } [
        dup rematerialize-constants? set-global
        "CALLBACK REMATERIALIZATION " write .
        "resource:basis/compiler/tests/alien-large-return.factor" run-file
    ] each
] each
test-failures get dup . empty? [ "CALLBACK ALL PASS" print 0 ] [ 1 ] if exit
