USING: vocabs.refresh ;
<< refresh-all >>
USING: command-line compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.backtracking compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.verifier io kernel namespaces sequences system tools.test ;
f silent-tests? set-global
f restartable-tests? set-global
t check-allocation? set-global
t check-ssa? set-global
command-line get first "on" = rematerialize-constants? set-global
value-flow-verifier-enabled? t assert=
"compiler.cfg.register-allocation.backtracking" test
test-failures get empty? t assert=
"BT-PROFITABILITY-GATE PASS" print
0 exit
