IN: temporary
USING: alien compiler kernel namespaces namespaces test ;

FUNCTION: void ffi_test_0 ; compiled
[ ] [ ffi_test_0 ] unit-test

FUNCTION: int ffi_test_1 ; compiled
[ 3 ] [ ffi_test_1 ] unit-test

FUNCTION: int ffi_test_2 int x int y ; compiled
[ 5 ] [ 2 3 ffi_test_2 ] unit-test

FUNCTION: int ffi_test_3 int x int y int z int t ; compiled
[ 25 ] [ 2 3 4 5 ffi_test_3 ] unit-test

FUNCTION: float ffi_test_4 ; compiled
[ 1.5 ] [ ffi_test_4 ] unit-test

FUNCTION: double ffi_test_5 ; compiled
[ 1.5 ] [ ffi_test_5 ] unit-test

FUNCTION: double ffi_test_6 float x float y ; compiled
[ 6.0 ] [ 3.0 2.0 ffi_test_6 ] unit-test

FUNCTION: double ffi_test_7 double x double y ; compiled
[ 6.0 ] [ 3.0 2.0 ffi_test_7 ] unit-test

FUNCTION: double ffi_test_8 double x float y double z float t int w ; compiled
[ 19.0 ] [ 3.0 2.0 1.0 6.0 7 ffi_test_8 ] unit-test

FUNCTION: int ffi_test_9 int a int b int c int d int e int f int g ; compiled
[ 28 ] [ 1 2 3 4 5 6 7 ffi_test_9 ] unit-test

FUNCTION: int ffi_test_10 int a int b double c int d float e int f int g int h ; compiled
[ -34 ] [ 1 2 3 4 5 6 7 8 ffi_test_10 ] unit-test

BEGIN-STRUCT: foo
    FIELD: int x
    FIELD: int y
END-STRUCT

: make-foo ( x y -- foo )
    "foo" <c-object> [ set-foo-y ] keep [ set-foo-x ] keep ;

FUNCTION: int ffi_test_11 int a foo b int c ; compiled

[ 14 ] [ 1 2 3 make-foo 4 ffi_test_11 ] unit-test

BEGIN-STRUCT: rect
    FIELD: float x
    FIELD: float y
    FIELD: float w
    FIELD: float h
END-STRUCT

: <rect>
    "rect" <c-object>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

FUNCTION: int ffi_test_12 int a int b rect c int d int e int f ; compiled

[ 45 ] [ 1 2 3 4 5 6 <rect> 7 8 9 ffi_test_12 ] unit-test

FUNCTION: int ffi_test_13 int a int b int c int d int e int f int g int h int i int j int k ; compiled

[ 66 ] [ 1 2 3 4 5 6 7 8 9 10 11 ffi_test_13 ] unit-test

FUNCTION: foo ffi_test_14 int x int y ;

cpu "x86" = macosx? and [
    \ ffi_test_14 compile
    [ 11 6 ] [ 11 6 ffi_test_14 dup foo-x swap foo-y ] unit-test
] when
