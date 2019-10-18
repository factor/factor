IN: temporary
USING: alien compiler kernel namespaces namespaces test
sequences inference errors words arrays parser quotations ;

FUNCTION: void ffi_test_0 ;
[ ] [ ffi_test_0 ] unit-test

FUNCTION: int ffi_test_1 ;
[ 3 ] [ ffi_test_1 ] unit-test

FUNCTION: int ffi_test_2 int x int y ;
[ 5 ] [ 2 3 ffi_test_2 ] unit-test

FUNCTION: int ffi_test_3 int x int y int z int t ;
[ 25 ] [ 2 3 4 5 ffi_test_3 ] unit-test

FUNCTION: float ffi_test_4 ;
[ 1.5 ] [ ffi_test_4 ] unit-test

FUNCTION: double ffi_test_5 ;
[ 1.5 ] [ ffi_test_5 ] unit-test

FUNCTION: int ffi_test_9 int a int b int c int d int e int f int g ;
[ 28 ] [ 1 2 3 4 5 6 7 ffi_test_9 ] unit-test

C-STRUCT: foo
    { "int" "x" }
    { "int" "y" }
;

: make-foo ( x y -- foo )
    "foo" <c-object> [ set-foo-y ] keep [ set-foo-x ] keep ;

FUNCTION: int ffi_test_11 int a foo b int c ;

[ 14 ] [ 1 2 3 make-foo 4 ffi_test_11 ] unit-test

FUNCTION: int ffi_test_13 int a int b int c int d int e int f int g int h int i int j int k ;

[ 66 ] [ 1 2 3 4 5 6 7 8 9 10 11 ffi_test_13 ] unit-test

FUNCTION: foo ffi_test_14 int x int y ;

[ 11 6 ] [ 11 6 ffi_test_14 dup foo-x swap foo-y ] unit-test

FUNCTION: char* ffi_test_15 char* x char* y ;

[ "foo" ] [ "xy" "zt" ffi_test_15 ] unit-test
[ "bar" ] [ "xy" "xy" ffi_test_15 ] unit-test

C-STRUCT: bar
    { "long" "x" }
    { "long" "y" }
    { "long" "z" }
;

FUNCTION: bar ffi_test_16 long x long y long z ;

[ 11 6 -7 ] [
    11 6 -7 ffi_test_16 dup bar-x over bar-y rot bar-z
] unit-test

C-STRUCT: tiny
    { "int" "x" }
;

FUNCTION: tiny ffi_test_17 int x ;

[ 11 ] [ 11 ffi_test_17 tiny-x ] unit-test

[ t ] [ [ [ alien-indirect ] infer ] catch inference-error? ] unit-test

: indirect-test-1
    "int" { } "cdecl" alien-indirect ;

: short-effect
    dup effect-in length swap effect-out length 2array nip ;

[ { 1 1 } ] [ [ indirect-test-1 ] infer short-effect ] unit-test

[ 3 ] [ "ffi_test_1" f dlsym indirect-test-1 ] unit-test

: indirect-test-2
    "int" { "int" "int" } "cdecl" alien-indirect ;

[ { 3 1 } ] [ [ indirect-test-2 ] infer short-effect ] unit-test

[ 5 ]
[ 2 3 "ffi_test_2" f dlsym indirect-test-2 ]
unit-test

: indirect-test-3
    "int" { "int" "int" "int" "int" } "stdcall" alien-indirect ;

! This is a hack -- words are compiled before top-level forms
! run.

DEFER: >> delimiter
: << \ >> parse-until >quotation call ; parsing

<< "f-stdcall" f "stdcall" add-library >>

[ f ] [ "f-stdcall" load-library ] unit-test
[ "stdcall" ] [ "f-stdcall" library library-abi ] unit-test

: ffi_test_18 ( w x y z -- int )
    "int" "f-stdcall" "ffi_test_18" { "int" "int" "int" "int" }
    alien-invoke ;

[ 25 ] [ 2 3 4 5 ffi_test_18 ] unit-test

: ffi_test_19 ( x y z -- bar )
    "bar" "f-stdcall" "ffi_test_19" { "long" "long" "long" }
    alien-invoke ;

[ 11 6 -7 ] [
    11 6 -7 ffi_test_19 dup bar-x over bar-y rot bar-z
] unit-test

! Tests with float args go last, we can't pass float args on
! ARM yet
FUNCTION: double ffi_test_6 float x float y ;
[ 6.0 ] [ 3.0 2.0 ffi_test_6 ] unit-test

FUNCTION: double ffi_test_7 double x double y ;
[ 6.0 ] [ 3.0 2.0 ffi_test_7 ] unit-test

FUNCTION: double ffi_test_8 double x float y double z float t int w ;
[ 19.0 ] [ 3.0 2.0 1.0 6.0 7 ffi_test_8 ] unit-test

FUNCTION: int ffi_test_10 int a int b double c int d float e int f int g int h ;
[ -34 ] [ 1 2 3.0 4 5.0 6 7 8 ffi_test_10 ] unit-test

FUNCTION: void ffi_test_20 double x1, double x2, double x3,
	double y1, double y2, double y3,
	double z1, double z2, double z3 ;

[ ] [ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 ffi_test_20 ] unit-test

FUNCTION: longlong ffi_test_21 long x long y ;

[ 121932631112635269 ]
[ 123456789 987654321 ffi_test_21 ] unit-test

FUNCTION: long ffi_test_22 long x longlong y longlong z ;

[ 987655432 ]
[ 1111 121932631112635269 123456789 ffi_test_22 ] unit-test

! Put this last; it doesn't work on AMD64 yet
C-STRUCT: rect
    { "float" "x" }
    { "float" "y" }
    { "float" "w" }
    { "float" "h" }
;

: <rect>
    "rect" <c-object>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

FUNCTION: int ffi_test_12 int a int b rect c int d int e int f ;

[ 45 ] [ 1 2 3.0 4.0 5.0 6.0 <rect> 7 8 9 ffi_test_12 ] unit-test

FUNCTION: float ffi_test_23 ( float[3] x, float[3] y ) ;

[ 32.0 ] [ { 1.0 2.0 3.0 } >float-array { 4.0 5.0 6.0 } >float-array ffi_test_23 ] unit-test
