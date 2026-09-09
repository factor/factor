USING: assocs compiler.errors debugger io kernel namespaces sequences tools.test vocabs.loader ;
f restartable-tests? set-global
"resource:reference/arm64-varargs-outgoing-20260908/refresh.factor" run-file
{ "stack-checker.alien" "compiler.cfg.builder.alien" } [ test ] each
"resource:basis/compiler/tests/alien-varargs-outgoing.factor" run-test-file
"resource:basis/compiler/tests/alien-small-floats.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
