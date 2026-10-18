USING: alien alien.c-types alien.libraries alien.syntax arrays environment io
io.pathnames kernel locals math math.floats.env memory namespaces prettyprint sequences tools.test ;
IN: compiler.tests.alien-linux-runtime
<< "linux-runtime" "FACTOR_REPRO_LIBRARY" os-env [ ] [
    "resource:libfactor-ffi-test.so" absolute-path
] if* cdecl add-library >>
LIBRARY: linux-runtime
FUNCTION: double ffi_fp_divide ( double a, double b )
0 "fp-status-cases" set-global
: fp-status-case ( -- ) "fp-status-cases" [ 1 + ] change-global ;

:: fp-divide-trap-case ( flag a b -- )
    [ flag 1array [ a b ffi_fp_divide drop ] with-fp-traps ]
    [ flag vm-error-exception-flag? ] floating-point-must-fail-with ;

{ t } [
    [ clear-fp-exception-flags 1.0 0.0 ffi_fp_divide drop
      +fp-zero-divide+ fp-exception-flags member? ] without-fp-traps fp-status-case
] floating-point-unit-test
{ 2.0 } [ 4.0 2.0 ffi_fp_divide fp-status-case ] floating-point-unit-test

floating-point-supported? [
    fp-traps-supported? [
        { +fp-zero-divide+ } [ +fp-zero-divide+ fp-traps member? ] with-fp-traps
    ] [ f ] if
] [ t ] if [
    {
        { +fp-invalid-operation+ 0.0 0.0 }
        { +fp-zero-divide+ 1.0 0.0 }
        { +fp-overflow+ 1.7976931348623157e308 0.5 }
        { +fp-underflow+ 2.2250738585072014e-308 1.7976931348623157e308 }
        { +fp-inexact+ 1.0 3.0 }
    } [ first3 fp-divide-trap-case ] each
    { 2.0 } [ 4.0 2.0 ffi_fp_divide fp-status-case ] floating-point-unit-test
    ! Exception recovery must leave only Factor frames in captured callstacks.
    { } [ compact-gc ] unit-test
    floating-point-supported?
    [ "FFI-COVERAGE native-fp-trap executed=5" ]
    [ "FFI-COVERAGE native-fp-trap executed=0" ] if print
] [ "FFI-SKIP native-fp-trap reason=effective-trap-mask-unavailable" print ] if

"FFI-COVERAGE fp-status executed=" write "fp-status-cases" get .
