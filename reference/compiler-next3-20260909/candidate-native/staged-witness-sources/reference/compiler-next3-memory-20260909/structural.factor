USING: vocabs.refresh ;
<< refresh-all >>
USING: compiler.cfg.memory-optimization io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
f silent-tests? set-global
"resource:basis/compiler/cfg/memory-optimization/memory-optimization-tests.factor" run-file
test-failures get empty? t assert=
"MEMORY STRUCTURAL PASS" print
0 exit
