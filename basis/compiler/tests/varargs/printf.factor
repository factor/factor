! Run in a separate process: printf writes through the native C stdout stream.
USING: alien alien.c-types alien.libraries alien.syntax combinators
io.pathnames kernel libc system ;
FROM: alien.c-types => float ;
IN: compiler.tests.alien-varargs.printf
<<
"printf-fixture" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: printf-fixture
FUNCTION: void* va_printf_pointer ( )
: tested-printf ( format text number width precision value wide -- count )
    va_printf_pointer
    int { c-string c-string char int int float longlong } cdecl 1 alien-indirect-varargs ;
LIBRARY: libc
FUNCTION-ALIAS: tested-fflush int fflush ( void* stream )
"%s:%d:%*.*f:%lld\n" "value" -42 7 3 1.25 -1234567890123 tested-printf
33 = [ "printf returned the wrong output length" throw ] unless
f tested-fflush 0 = [ "fflush failed" throw ] unless
