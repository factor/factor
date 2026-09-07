! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators destructors io.pathnames kernel locals
math memory sequences system tools.test ;
IN: compiler.tests.alien-large-return

<<
"large-return-test" "resource:" absolute-path
os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>

LIBRARY: large-return-test

STRUCT: large-return { x longlong } { y longlong } { z longlong } ;

FUNCTION: large-return ffi_test_large_return (
    longlong a, longlong b, longlong c, longlong d, longlong e,
    longlong f, longlong g, longlong h, longlong i )
FUNCTION: longlong ffi_test_large_return_callback ( void* callback )

: large-return-values ( result -- x y z )
    [ x>> ] [ y>> ] [ z>> ] tri ;

! X8 holds the result pointer without consuming X0-X7. The ninth argument
! must remain the first stack argument, including for an indirect call.
{ 6 15 24 } [
    1 2 3 4 5 6 7 8 9 ffi_test_large_return large-return-values
] unit-test

{ -6 -15 -24 } [
    -1 -2 -3 -4 -5 -6 -7 -8 -9 ffi_test_large_return large-return-values
] unit-test

: indirect-large-return ( a b c d e f g h i ptr -- result )
    large-return { longlong longlong longlong longlong longlong
                   longlong longlong longlong longlong }
    cdecl alien-indirect ;

{ 6 15 24 } [
    1 2 3 4 5 6 7 8 9
    "ffi_test_large_return" "large-return-test" library-dll dlsym
    indirect-large-return large-return-values
] unit-test

: large-return-callback ( -- callback )
    large-return { longlong longlong longlong longlong longlong
                   longlong longlong longlong longlong }
    cdecl [| a b c d e f g h i |
        compact-gc
        large-return <struct>
            a b + c + >>x
            d e + f + >>y
            g h + i + >>z
    ] alien-callback ;

! A real C caller validates the callback ABI; a Factor-only round trip
! could conceal matching mistakes in caller and callee lowering.
{ 45 } [
    large-return-callback [ ffi_test_large_return_callback ] with-callback
] unit-test

: nested-large-return-callback ( -- callback )
    large-return { longlong longlong longlong longlong longlong
                   longlong longlong longlong longlong }
    cdecl [ compact-gc ffi_test_large_return ] alien-callback ;

! Preserve the outer C result pointer while the callback invokes another
! C function with its own indirect result area.
{ 45 } [
    nested-large-return-callback
    [ ffi_test_large_return_callback ] with-callback
] unit-test
