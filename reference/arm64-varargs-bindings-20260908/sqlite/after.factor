USING: assocs compiler.errors db.sqlite.ffi debugger io kernel namespaces sequences system tools.test vocabs.loader ;
IN: sqlite-binding-test-driver
f restartable-tests? set-global
"db.sqlite.ffi" reload
sqlite3_libversion print flush
"db.sqlite.ffi" test
"resource:basis/compiler/tests/sqlite-varargs.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
