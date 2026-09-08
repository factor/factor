USING: assocs compiler.errors debugger io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
"resource:basis/compiler/tests/alien-small-floats.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? flush exit
