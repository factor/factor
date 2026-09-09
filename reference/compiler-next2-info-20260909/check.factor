USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors prettyprint compiler.cfg.checker compiler.tree.optimizer debugger io kernel
namespaces sequences system tools.test tools.test.private ;
t check-allocation? set-global t check-ssa? set-global t check-optimizer? set-global
f restartable-tests? set-global
"compiler.tree.propagation" test
"classes.algebra" test
"CLASS-INFO-FAILURES " write test-failures get length .
test-failures get [ error>> error. ] each
test-failures get empty? [ 0 ] [ 1 ] if exit
