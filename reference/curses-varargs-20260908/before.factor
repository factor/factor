USING: accessors assocs compiler.errors curses.ffi debugger io kernel
namespaces parser prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
"curses.ffi" reload
"resource:extra/curses/ffi/native/headless.factor" run-test-file
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
:test-failures compiler-errors get values [ print-error ] each
 test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
