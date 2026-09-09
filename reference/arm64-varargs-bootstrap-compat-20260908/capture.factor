USING: alien alien.accessors alien.c-types alien.libraries alien.parser
alien.private alien.syntax assocs bootstrap.image.private compiler.constants
cpu.arm.64.assembler cpu.arm.64.assembler.registers hashtables io
kernel kernel.private locals math memory namespaces parser sequences
system tools.test vocabs ;
IN: scratchpad

! Save-area address is obtained independently of the new compiler input path.
: saved-native-stack ( -- ptr )
    void* { } cdecl [ X0 CTX context-callstack-save-offset [+] LDR ] alien-assembly ;

:: captured-values ( -- values )
    saved-native-stack :> saved
    8 <iota> [ 8 * 240 + saved swap alien-signed-8 ] map
    8 <iota> [ 16 * 112 + saved swap alien-double ] map append ;

: capture-callback ( -- alien )
    long { long long long long long long long long
           double double double double double double double double } cdecl [
        2drop 2drop 2drop 2drop 2drop 2drop 2drop 2drop
        compact-gc
        captured-values
        { 11 22 33 44 55 66 77 88 1.25 2.25 3.25 4.25 5.25 6.25 7.25 8.25 } =
        [ 42 ] [ -1 ] if
    ] alien-callback ;

<< "entry-capture" "/tmp/arm64-varargs-entry-capture.dylib" cdecl add-library >>
LIBRARY: entry-capture
FUNCTION: long call_capture ( void* callback )

:: exercise ( -- n )
    capture-callback :> ordinary
    ordinary callbacks get value-at -1 <callback> :> variadic
    variadic call_capture
    variadic free-callback
    ordinary unregister-and-free-callback ;

! Old images reject variadic allocation until the source-level upgrade runs.
[ exercise ] must-fail
"bootstrap.compat.arm64" require
{ 42 } [ exercise ] unit-test
{ 42 } [ exercise ] unit-test
test-failures get empty? [ "entry capture tests failed" throw ] unless
"Upgraded old seed passes native register capture and compacting GC" print
