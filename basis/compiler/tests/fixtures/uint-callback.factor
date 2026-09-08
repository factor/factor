USING: alien alien.c-types alien.libraries alien.syntax destructors
environment io.pathnames kernel locals system tools.test ;
IN: compiler.tests.alien-linux-regressions
<< "linux-regressions" "FACTOR_REPRO_LIBRARY" os-env [ ] [
    "resource:" absolute-path
    os macos? [ "libfactor-ffi-test.dylib" ] [ "libfactor-ffi-test.so" ] if append-path
] if* cdecl add-library >>
LIBRARY: linux-regressions
FUNCTION: ulonglong ffi_uint_callback ( void* cb )
: uint-callback ( -- cb )
    ulonglong { int int int int int int int uint } cdecl
    [| a b c d e f g x | x ] alien-callback ;
{ 3000000000 } [ uint-callback [ ffi_uint_callback ] with-callback ] unit-test
