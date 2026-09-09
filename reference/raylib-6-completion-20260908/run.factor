USING: alien alien.libraries assocs compiler.errors io.pathnames
kernel namespaces parser prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
f load-help? set-global
"raylib" reload
"raylib" "/tmp/factor-raylib-varargs-6.0/src/libraylib.dylib" cdecl update-library
"raylib-api60" "/tmp/libraylib-api60.dylib" cdecl update-library
"raylib" test
"resource:extra/raylib/native/binary.factor" run-test-file
"resource:extra/raylib/native/ownership.factor" run-test-file
"resource:extra/raylib/native/boundaries.factor" run-test-file
:test-failures
compiler-errors get assoc-size .
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
