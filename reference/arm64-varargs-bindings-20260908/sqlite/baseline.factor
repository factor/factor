USING: assocs compiler.errors debugger io kernel namespaces parser sequences system tools.test vocabs.loader ;
IN: sqlite-binding-test-driver
f restartable-tests? set-global
"db.sqlite.ffi" reload
"/tmp/sqlite-old-ffi.factor" run-file
"resource:reference/arm64-varargs-bindings-20260908/sqlite/baseline-tests.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
