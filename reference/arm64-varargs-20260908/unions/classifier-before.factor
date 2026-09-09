USING: assocs compiler.errors debugger io kernel namespaces parser sequences system tools.test ;
IN: arm64-union-test-driver
f restartable-tests? set-global
"resource:basis/compiler/tests/arm64-unions/cases.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
