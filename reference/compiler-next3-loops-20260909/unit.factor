USING: vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.loop-optimization compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.register-allocation.rematerialization compiler.cfg.value-numbering
io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
t check-ssa? set-global t check-allocation? set-global
f global-value-numbering? set-global f rematerialize-constants? set-global
value-flow-verifier-enabled? t assert=
"compiler.cfg.loop-optimization" test
test-failures get dup . empty? t assert=
"LICM UNIT PASS" print
0 exit
