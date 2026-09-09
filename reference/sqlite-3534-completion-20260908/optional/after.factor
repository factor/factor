USING: alien.c-types alien.libraries assocs compiler.errors debugger
environment io kernel namespaces parser prettyprint sequences system tools.test vocabs.loader ;
IN: sqlite-optional-driver
f restartable-tests? set-global
"db.sqlite.ffi" reload
"SQLITE_3534_BINDINGS" os-env run-file
"resource:reference/sqlite-3534-completion-20260908/optional/tests.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get length .
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
