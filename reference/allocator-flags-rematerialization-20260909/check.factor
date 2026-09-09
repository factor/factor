USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.value-numbering io kernel locals namespaces prettyprint
sequences tools.test tools.test.private words ;
IN: allocator-flags-rematerialization-check
f restartable-tests? set-global
t silent-tests? set-global
t check-allocation? set-global
t check-ssa? set-global
{ f t } [| gvn? |
    gvn? global-value-numbering? set-global
    "REMAT-TEST-GVN " write gvn? . flush
    "compiler.cfg.register-allocation.rematerialization" test
    "compiler.cfg.register-allocation.verifier.rematerialization" test
] each
"REMAT-TEST-FAILURES " write test-failures get length . flush
test-failures get empty? [ ] [ :test-failures ] if
