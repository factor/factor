USING: vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.verifier io kernel namespaces prettyprint
sequences system tools.test ;
t check-allocation? set-global
t check-ssa? set-global
value-flow-verifier-enabled? t assert=
"compiler.cfg.register-allocation.chordal.spilling" test
test-failures get dup . empty? [ 0 ] [ 1 ] if exit
