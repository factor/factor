USING: alien alien.accessors alien.c-types alien.libraries alien.syntax
arrays destructors environment io io.pathnames kernel locals math memory
namespaces prettyprint sequences tools.test ;
IN: compiler.tests.alien-linux-runtime
<< "linux-runtime" "FACTOR_REPRO_LIBRARY" os-env [ ] [
    "resource:libfactor-ffi-test.so" absolute-path
] if* cdecl add-library >>
LIBRARY: linux-runtime
FUNCTION: int abi_call_int ( void* cb, int x )
FUNCTION: int abi_pointer_gc ( void* cb )
0 "runtime-callback-cases" set-global
: runtime-callback-case ( -- ) "runtime-callback-cases" [ 1 + ] change-global ;

: inner-callback ( -- cb )
    int { int } cdecl [ 4096 swap <array> compact-gc sum ] alien-callback ;
: outer-callback ( -- cb )
    int { int } cdecl [| x |
        inner-callback [ x abi_call_int ] with-callback 1 +
    ] alien-callback ;
{ 12289 } [ outer-callback [ 3 abi_call_int ] with-callback runtime-callback-case ] unit-test

: pointer-callback ( -- cb )
    void { void* } cdecl [| ptr |
        4096 7 <array> compact-gc sum drop
        0xa5 ptr 0 set-alien-unsigned-1
    ] alien-callback ;
{ 1 } [ pointer-callback [ abi_pointer_gc ] with-callback runtime-callback-case ] unit-test

"resource:basis/compiler/tests/fixtures/fp-status.factor" run-test-file
"FFI-COVERAGE runtime-callbacks executed=" write "runtime-callback-cases" get .
