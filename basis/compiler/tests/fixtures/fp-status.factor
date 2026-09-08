USING: alien alien.c-types alien.libraries alien.syntax environment io
io.pathnames kernel math math.floats.env namespaces prettyprint sequences tools.test ;
IN: compiler.tests.alien-linux-runtime
<< "linux-runtime" "FACTOR_REPRO_LIBRARY" os-env [ ] [
    "resource:libfactor-ffi-test.so" absolute-path
] if* cdecl add-library >>
LIBRARY: linux-runtime
FUNCTION: double ffi_fp_divide ( double a, double b )
0 "fp-status-cases" set-global
: fp-status-case ( -- ) "fp-status-cases" [ 1 + ] change-global ;

{ t } [
    [ clear-fp-exception-flags 1.0 0.0 ffi_fp_divide drop
      +fp-zero-divide+ fp-exception-flags member? ] without-fp-traps fp-status-case
] unit-test
{ 2.0 } [ 4.0 2.0 ffi_fp_divide fp-status-case ] unit-test

{ +fp-zero-divide+ } [ +fp-zero-divide+ fp-traps member? ] with-fp-traps [
    [ { +fp-zero-divide+ } [ 1.0 0.0 ffi_fp_divide drop ] with-fp-traps ]
    [ +fp-zero-divide+ vm-error-exception-flag? ] must-fail-with
    { 2.0 } [ 4.0 2.0 ffi_fp_divide fp-status-case ] unit-test
    "FFI-COVERAGE native-fp-trap executed=1" print
] [ "FFI-SKIP native-fp-trap reason=effective-trap-mask-unavailable" print ] if

"FFI-COVERAGE fp-status executed=" write "fp-status-cases" get .
