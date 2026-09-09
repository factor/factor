USING: alien alien.libraries assocs compiler.errors db.sqlite.ffi debugger
environment io kernel namespaces sequences parser system tools.test vocabs.loader ;
IN: sqlite.release.core.driver
f restartable-tests? set-global
"db.sqlite.ffi" reload
"SQLITE_3534_BINDINGS" os-env run-file
"resource:reference/sqlite-3534-completion-20260908/core-tests.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
