USING: vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.loop-optimization compiler.cfg.memory-optimization
compiler.cfg.representations.selection compiler.cfg.slp
compiler.cfg.register-allocation compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.register-allocation.rematerialization compiler.cfg.value-numbering
io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
t check-ssa? set-global t check-allocation? set-global
linear-scan-allocator register-allocator set-global
f global-value-numbering? set-global f rematerialize-constants? set-global
t loop-optimization? set-global t memory-optimization? set-global
t conversion-aware-representation-costs? set-global t automatic-slp? set-global
value-flow-verifier-enabled? t assert=
{ "compiler.cfg.loop-optimization" "compiler.cfg.memory-optimization"
  "compiler.cfg.memory-optimization.validation"
  "compiler.cfg.representations" "compiler.cfg.slp" } [ test ] each
test-failures get empty? t assert=
"NEXT3 COMBINED CHECK PASS" print
0 exit
