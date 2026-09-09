USING: alien.c-types assocs db.sqlite.ffi debugger io kernel namespaces prettyprint
sequences system tools.test vocabs.loader words ;
IN: sqlite-optional-baseline
f restartable-tests? set-global
"db.sqlite.ffi" reload
"resource:reference/sqlite-3534-completion-20260908/optional/baseline-tests.factor" run-test-file
:test-failures
test-failures get length .
test-failures get empty? 0 1 ? exit
