USING: alien alien.c-types alien.libraries alien.syntax compiler compiler.units continuations io io.pathnames
kernel kernel.private literals math.floats.env math.floats.env.private
sequences threads ;
IN: s390x.recovery.private.child
<< "s390x-private-child" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: s390x-private-child
FUNCTION: int ffi_test_1 ( )
FUNCTION: int ffi_test_2 ( int x, int y )
FUNCTION: float ffi_test_4 ( )
FUNCTION: double ffi_test_6 ( float x, float y )
FUNCTION: double ffi_fp_divide ( double x, double y )
{ ffi_test_1 ffi_test_2 ffi_test_4 ffi_test_6 ffi_fp_divide } compile
ffi_test_1 3 = [ ] [ "target FFI mismatch" throw ] if
2 3 ffi_test_2 5 = [ ] [ "target integer FFI mismatch" throw ] if
ffi_test_4 1.5 = [ ] [ "target float FFI mismatch" throw ] if
2.0 3.0 ffi_test_6 6.0 = [ ] [ "target promoted double FFI mismatch" throw ] if
12.0 2.0 ffi_fp_divide 6.0 = [ ] [ "target double FFI mismatch" throw ] if
[ { +fp-zero-divide+ } [ 1.0 0.0 ffi_fp_divide ] with-fp-traps drop "missing vector trap" throw ]
[ dup 2 head ${ KERNEL-ERROR ERROR-FP-TRAP } =
  [ +fp-zero-divide+ vm-error-exception-flag? [ ] [ "wrong vector trap flags" throw ] if ]
  [ "wrong vector trap type" throw ] if ] recover
"PRIVATE-DEFAULT-CHILD-TARGET-FFI-VECTOR-TRAP-PASS" print flush
1000000000 sleep
