USING: parser vocabs.loader vocabs.refresh ;
<< refresh-all
"reference/compiler-next3-representations-20260909/workloads.factor" run-file >>
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.verifier compiler.cfg.value-numbering
arrays compiler.units compiler-next3-representation-workload
compiler.cfg.representations.selection io kernel locals math namespaces
prettyprint sequences system tools.test tools.test.private words ;
f restartable-tests? set-global
t silent-tests? set-global
t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
"compiler.cfg.representations" test
{ f t } [| enabled? |
    enabled? conversion-aware-representation-costs? set
    \ representation-loop-values 1array compile
    representation-loop-work
    "NAMED-WORKLOAD-PASS " write enabled? . flush
] each
"REPRESENTATION-FAILURES " write test-failures get length . flush
test-failures get empty? [ 0 ] [ :test-failures 1 ] if exit
