USING: assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
"compiler.cfg.builder.alien" reload
"resource:basis/compiler/cfg/builder/alien/alien-tests.factor" run-test-file
"resource:basis/compiler/cfg/instructions/instructions-tests.factor" run-test-file
:test-failures compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and
[ "Compiler refresh regressions passed" print 0 ] [ 1 ] if flush exit
