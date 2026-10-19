! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.complex alien.libraries alien.syntax compiler.units io io.pathnames kernel math ;
IN: mips.complex-validation
<< "mips-complex" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: mips-complex
FUNCTION: complex-float ffi_test_45 ( int x )
FUNCTION: complex-double ffi_test_46 ( int x )
FUNCTION: complex-float ffi_test_47 ( complex-float x, complex-double y )
: check-complex ( -- )
  3 ffi_test_45 C{ 3.0 0.0 } = [ ] [ "complex float return" throw ] if
  3 ffi_test_46 C{ 3.0 0.0 } = [ ] [ "complex double return" throw ] if
  C{ 1.0 2.0 } C{ 1.5 1.0 } ffi_test_47 C{ 4.0 4.0 } = [ ] [ "mixed complex arguments" throw ] if ;
{ ffi_test_45 ffi_test_46 ffi_test_47 check-complex } compile
check-complex "GNU complex returns and mixed arguments PASS" print flush
