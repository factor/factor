USING: alien alien.c-types alien.libraries assocs compiler.errors debugger
io kernel namespaces prettyprint sequences system tools.test vocabs.loader ;
IN: raylib.varargs.evidence
"raylib" reload
"raylib" library-dll dll-valid? [ "Raylib library is required" throw ] unless
f restartable-tests? set-global
"raylib" test
: test-status ( -- )
    test-failures get length "TEST FAILURES " write .
    compiler-errors get assoc-size "COMPILER ERRORS " write . ;
test-status
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
