! Unix exports these standard C names directly; run only in a subprocess.
USING: alien.c-types alien.syntax kernel libc ;
IN: compiler.tests.alien-varargs.printf-direct
LIBRARY: libc
FUNCTION-ALIAS: tested-printf int printf (
    c-string format, ... c-string text, char number,
    int width, int precision, float value, longlong wide )
FUNCTION-ALIAS: tested-fflush int fflush ( void* stream )
"%s:%d:%*.*f:%lld\n" "value" -42 7 3 1.25 -1234567890123 tested-printf
33 = [ "printf returned the wrong output length" throw ] unless
f tested-fflush 0 = [ "fflush failed" throw ] unless
