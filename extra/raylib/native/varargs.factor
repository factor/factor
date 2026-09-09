! Real raylib calls; no window, GPU, or event loop is initialized.
USING: alien alien.c-types alien.syntax alien.varargs arrays
continuations kernel locals namespaces raylib system tools.test ;
IN: raylib.tests

LIBRARY: raylib
FUNCTION-ALIAS: raylib-test-format c-string TextFormat (
    c-string text, ... int a, double b, int c, double d, int e )
FUNCTION-ALIAS: raylib-test-log void TraceLog (
    TraceLogLevel logLevel, c-string text, ... int value, double number )

{ "literal 100%" } [ "literal 100%%" text-format ] unit-test
{ "7/2.50/-3/4.5/11" } [
    "%d/%.2f/%d/%.1f/%d" 7 2.5 -3 4.5 11 raylib-test-format
] unit-test

! Native va_list callback cursors currently target ARM64.
cpu arm.64? [
    "resource:extra/raylib/native/callback.factor" run-test-file
] when
