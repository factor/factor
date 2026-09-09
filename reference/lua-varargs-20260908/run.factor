USING: alien alien.libraries assocs compiler.errors io.pathnames
kernel namespaces parser prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
"lua" reload
"liblua5.1" "resource:reference/lua-varargs-20260908/build/liblua5.1.dylib" absolute-path cdecl add-library
"lua-varargs-fixture" "resource:reference/lua-varargs-20260908/build/liblua-varargs-fixture.dylib" absolute-path cdecl add-library
"resource:reference/lua-varargs-20260908/api-probe.factor" run-test-file
"lua" test
"resource:extra/lua/native/varargs.factor" run-test-file
:test-failures
compiler-errors get assoc-size .
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
