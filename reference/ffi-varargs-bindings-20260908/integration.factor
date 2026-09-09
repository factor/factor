USING: alien alien.libraries assocs compiler.errors debugger io
kernel namespaces parser prettyprint sequences system tools.test vocabs.loader ;
IN: ffi.varargs.bindings.integration
f restartable-tests? set-global
{
 "raylib" "lua" "db.sqlite.ffi" "curses.ffi" "curl.ffi"
 "openssl.libcrypto" "unix.ffi" "x11.syntax" "x11.xlib"
} [ reload ] each
"raylib" library-dll dll-valid? [ "Raylib is required for integration" throw ] unless
"liblua5.1" library-dll dll-valid? [ "Lua is required for integration" throw ] unless
"lua-varargs-fixture" "/Users/erg/factor.worktrees/arm64-varargs-lua/reference/lua-varargs-20260908/build/liblua-varargs-fixture.dylib" cdecl add-library
{
 "resource:extra/raylib/raylib-tests.factor"
 "resource:extra/curses/ffi/ffi-tests.factor"
 "resource:basis/db/sqlite/ffi/ffi-tests.factor"
 "resource:basis/compiler/tests/sqlite-varargs.factor"
 "resource:extra/lua/lua-tests.factor"
 "resource:extra/lua/native/varargs.factor"
 "resource:extra/curl/ffi/ffi-tests.factor"
 "resource:basis/unix/ffi/ffi-tests.factor"
 "resource:basis/openssl/libcrypto/tests/varargs.factor"
 "resource:basis/x11/syntax/syntax-tests.factor"
 "resource:basis/x11/xlib/xlib-tests.factor"
} [ dup print flush run-test-file ] each
:test-failures compiler-errors get values [ print-error ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
