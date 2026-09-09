! Deliberately wrong fixed signature: demonstrates the native ABI distinction.
USING: alien.c-types alien.syntax assocs compiler.errors io kernel
namespaces raylib sequences system tools.test ;
IN: raylib.fixed-tail.control
LIBRARY: raylib
FUNCTION-ALIAS: fixed-format c-string TextFormat (
    c-string text, int a, double b, int c, double d, int e )
f restartable-tests? set-global
{ "7/2.50/-3/4.5/11" } [
    "%d/%.2f/%d/%.1f/%d" 7 2.5 -3 4.5 11 fixed-format
] unit-test
:test-failures
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
