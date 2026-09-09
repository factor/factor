USING: alien alien.libraries assocs compiler.errors db.sqlite.ffi debugger
environment help.lint io kernel namespaces parser sequences system tools.test vocabs.loader ;
IN: sqlite.release.regression.driver
f restartable-tests? set-global
"db.sqlite.ffi" reload
"SQLITE_3534_BINDINGS" os-env run-file
"sqlite" "SQLITE_3534_LIBRARY" os-env cdecl add-library
"db.sqlite.lib" reload
"db.sqlite.ffi" test
"db.sqlite" test
"db.sqlite.ffi" help-lint
:test-failures
:lint-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and
lint-failures get assoc-empty? and 0 1 ? exit
