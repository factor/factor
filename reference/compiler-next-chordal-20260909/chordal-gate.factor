USING: vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.verifier io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
t check-allocation? set-global
t check-ssa? set-global
value-flow-verifier-enabled? t assert=
"compiler.cfg.register-allocation.chordal" test
test-failures get empty? t assert=
"CHORDAL-GATE PASS" print
0 exit
