! Install as core/arm32-ffi-child/arm32-ffi-child.factor in a complete
! acceptance epoch. The parent launches this child without an explicit image.
USING: alien alien.c-types alien.libraries alien.syntax arrays compiler
compiler.units io io.pathnames kernel math system words ;
QUALIFIED-WITH: alien.c-types c
IN: arm32-ffi-child
<< "arm32-child-fixture" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: arm32-child-fixture
FUNCTION-ALIAS: child-ffi-int int ffi_test_2 ( int a, int b )
FUNCTION-ALIAS: child-ffi-seven int ffi_test_9 ( int a, int b, int c, int d, int e, int f, int g )
FUNCTION-ALIAS: child-ffi-float c:float ffi_test_4 ( )
FUNCTION-ALIAS: child-ffi-double c:double ffi_test_5 ( )
FUNCTION-ALIAS: child-ffi-float-args c:double ffi_test_6 ( c:float a, c:float b )
FUNCTION-ALIAS: child-ffi-double-args c:double ffi_test_7 ( c:double a, c:double b )
FUNCTION-ALIAS: child-ffi-mixed c:double ffi_test_8 ( c:double a, c:float b, c:double c, c:float d, int e )
: check ( -- )
    1 2 3 4 5 6 7 child-ffi-seven 28 = [ ] [ 1 exit ] if
    -123 23 child-ffi-int -100 = [ ] [ 3 exit ] if
    child-ffi-float 1.5 = [ ] [ 4 exit ] if
    child-ffi-double 1.5 = [ ] [ 5 exit ] if
    1.25 2.0 child-ffi-float-args 2.5 = [ ] [ 6 exit ] if
    -4.5 2.0 child-ffi-double-args -9.0 = [ ] [ 7 exit ] if
    1.25 2.0 3.0 4.0 5 child-ffi-mixed 19.5 = [ ] [ 8 exit ] if
    "ARM32 bare child target FFI seven-GP-argument PASS" print
    "ARM32 bare child target FFI integer/float/double/mixed PASS" print ;
: main ( -- )
    \ check 1array compile
    \ check word-optimized? [ check ] [ 2 exit ] if ;
MAIN: main
