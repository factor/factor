USING: alien alien.c-types alien.syntax compiler kernel
namespaces namespaces tools.test sequences stack-checker
stack-checker.errors words arrays parser quotations
continuations effects namespaces.private io io.streams.string
memory system threads tools.test math accessors combinators
specialized-arrays.float alien.libraries io.pathnames
io.backend ;
IN: compiler.tests.alien

<<
: libfactor-ffi-tests-path ( -- string )
    "resource:" (normalize-path)
    {
        { [ os winnt? ]  [ "libfactor-ffi-test.dll" ] }
        { [ os macosx? ] [ "libfactor-ffi-test.dylib" ] }
        { [ os unix?  ]  [ "libfactor-ffi-test.so" ] }
    } cond append-path ;

"f-cdecl" libfactor-ffi-tests-path "cdecl" add-library

"f-stdcall" libfactor-ffi-tests-path "stdcall" add-library
>>

LIBRARY: f-cdecl

FUNCTION: void ffi_test_0 ;
[ ] [ ffi_test_0 ] unit-test

FUNCTION: int ffi_test_1 ;
[ 3 ] [ ffi_test_1 ] unit-test

FUNCTION: int ffi_test_2 int x int y ;
[ 5 ] [ 2 3 ffi_test_2 ] unit-test
[ "hi" 3 ffi_test_2 ] must-fail

FUNCTION: int ffi_test_3 int x int y int z int t ;
[ 25 ] [ 2 3 4 5 ffi_test_3 ] unit-test

FUNCTION: float ffi_test_4 ;
[ 1.5 ] [ ffi_test_4 ] unit-test

FUNCTION: double ffi_test_5 ;
[ 1.5 ] [ ffi_test_5 ] unit-test

FUNCTION: int ffi_test_9 int a int b int c int d int e int f int g ;
[ 28 ] [ 1 2 3 4 5 6 7 ffi_test_9 ] unit-test
[ "a" 2 3 4 5 6 7 ffi_test_9 ] must-fail
[ 1 2 3 4 5 6 "a" ffi_test_9 ] must-fail

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
[ 1 2 ffi_test_15 ] must-fail

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

[ [ alien-indirect ] infer ] [ inference-error? ] must-fail-with

: indirect-test-1 ( ptr -- result )
    "int" { } "cdecl" alien-indirect ;

{ 1 1 } [ indirect-test-1 ] must-infer-as

[ 3 ] [ &: ffi_test_1 indirect-test-1 ] unit-test

: indirect-test-1' ( ptr -- )
    "int" { } "cdecl" alien-indirect drop ;

{ 1 0 } [ indirect-test-1' ] must-infer-as

[ ] [ &: ffi_test_1 indirect-test-1' ] unit-test

[ -1 indirect-test-1 ] must-fail

: indirect-test-2 ( x y ptr -- result )
    "int" { "int" "int" } "cdecl" alien-indirect gc ;

{ 3 1 } [ indirect-test-2 ] must-infer-as

[ 5 ]
[ 2 3 &: ffi_test_2 indirect-test-2 ]
unit-test

: indirect-test-3 ( a b c d ptr -- result )
    "int" { "int" "int" "int" "int" } "stdcall" alien-indirect
    gc ;

[ f ] [ "f-stdcall" load-library f = ] unit-test
[ "stdcall" ] [ "f-stdcall" library abi>> ] unit-test

: ffi_test_18 ( w x y z -- int )
    "int" "f-stdcall" "ffi_test_18" { "int" "int" "int" "int" }
    alien-invoke gc ;

[ 25 ] [ 2 3 4 5 ffi_test_18 ] unit-test

: ffi_test_19 ( x y z -- bar )
    "bar" "f-stdcall" "ffi_test_19" { "long" "long" "long" }
    alien-invoke gc ;

[ 11 6 -7 ] [
    11 6 -7 ffi_test_19 dup bar-x over bar-y rot bar-z
] unit-test

FUNCTION: double ffi_test_6 float x float y ;
[ 6.0 ] [ 3.0 2.0 ffi_test_6 ] unit-test
[ "a" "b" ffi_test_6 ] must-fail

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

! Make sure XT doesn't get clobbered in stack frame

: ffi_test_31 ( a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a -- result y )
    "int"
    "f-cdecl" "ffi_test_31"
    { "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" }
    alien-invoke gc 3 ;

[ 861 3 ] [ 42 [ ] each ffi_test_31 ] unit-test

: ffi_test_31_point_5 ( a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a -- result )
    "float"
    "f-cdecl" "ffi_test_31_point_5"
    { "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" "float" }
    alien-invoke ;

[ 861.0 ] [ 42 [ >float ] each ffi_test_31_point_5 ] unit-test

FUNCTION: longlong ffi_test_21 long x long y ;

[ 121932631112635269 ]
[ 123456789 987654321 ffi_test_21 ] unit-test

FUNCTION: long ffi_test_22 long x longlong y longlong z ;

[ 987655432 ]
[ 1111 121932631112635269 123456789 ffi_test_22 ] unit-test

[ 1111 f 123456789 ffi_test_22 ] must-fail

C-STRUCT: rect
    { "float" "x" }
    { "float" "y" }
    { "float" "w" }
    { "float" "h" }
;

: <rect> ( x y w h -- rect )
    "rect" <c-object>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

FUNCTION: int ffi_test_12 int a int b rect c int d int e int f ;

[ 45 ] [ 1 2 3.0 4.0 5.0 6.0 <rect> 7 8 9 ffi_test_12 ] unit-test

[ 1 2 { 1 2 3 } 7 8 9 ffi_test_12 ] must-fail

FUNCTION: float ffi_test_23 ( float[3] x, float[3] y ) ;

[ 32.0 ] [
    { 1.0 2.0 3.0 } >float-array
    { 4.0 5.0 6.0 } >float-array
    ffi_test_23
] unit-test

! Test odd-size structs
C-STRUCT: test-struct-1 { { "char" 1 } "x" } ;

FUNCTION: test-struct-1 ffi_test_24 ;

[ B{ 1 } ] [ ffi_test_24 ] unit-test

C-STRUCT: test-struct-2 { { "char" 2 } "x" } ;

FUNCTION: test-struct-2 ffi_test_25 ;

[ B{ 1 2 } ] [ ffi_test_25 ] unit-test

C-STRUCT: test-struct-3 { { "char" 3 } "x" } ;

FUNCTION: test-struct-3 ffi_test_26 ;

[ B{ 1 2 3 } ] [ ffi_test_26 ] unit-test

C-STRUCT: test-struct-4 { { "char" 4 } "x" } ;

FUNCTION: test-struct-4 ffi_test_27 ;

[ B{ 1 2 3 4 } ] [ ffi_test_27 ] unit-test

C-STRUCT: test-struct-5 { { "char" 5 } "x" } ;

FUNCTION: test-struct-5 ffi_test_28 ;

[ B{ 1 2 3 4 5 } ] [ ffi_test_28 ] unit-test

C-STRUCT: test-struct-6 { { "char" 6 } "x" } ;

FUNCTION: test-struct-6 ffi_test_29 ;

[ B{ 1 2 3 4 5 6 } ] [ ffi_test_29 ] unit-test

C-STRUCT: test-struct-7 { { "char" 7 } "x" } ;

FUNCTION: test-struct-7 ffi_test_30 ;

[ B{ 1 2 3 4 5 6 7 } ] [ ffi_test_30 ] unit-test

C-STRUCT: test-struct-8 { "double" "x" } { "double" "y" } ;

FUNCTION: double ffi_test_32 test-struct-8 x int y ;

[ 9.0 ] [
    "test-struct-8" <c-object>
    1.0 over set-test-struct-8-x
    2.0 over set-test-struct-8-y
    3 ffi_test_32
] unit-test

C-STRUCT: test-struct-9 { "float" "x" } { "float" "y" } ;

FUNCTION: double ffi_test_33 test-struct-9 x int y ;

[ 9.0 ] [
    "test-struct-9" <c-object>
    1.0 over set-test-struct-9-x
    2.0 over set-test-struct-9-y
    3 ffi_test_33
] unit-test

C-STRUCT: test-struct-10 { "float" "x" } { "int" "y" } ;

FUNCTION: double ffi_test_34 test-struct-10 x int y ;

[ 9.0 ] [
    "test-struct-10" <c-object>
    1.0 over set-test-struct-10-x
    2 over set-test-struct-10-y
    3 ffi_test_34
] unit-test

C-STRUCT: test-struct-11 { "int" "x" } { "int" "y" } ;

FUNCTION: double ffi_test_35 test-struct-11 x int y ;

[ 9.0 ] [
    "test-struct-11" <c-object>
    1 over set-test-struct-11-x
    2 over set-test-struct-11-y
    3 ffi_test_35
] unit-test

C-STRUCT: test-struct-12 { "int" "a" } { "double" "x" } ;

: make-struct-12 ( x -- alien )
    "test-struct-12" <c-object>
    [ set-test-struct-12-x ] keep ;

FUNCTION: double ffi_test_36 ( test-struct-12 x ) ;

[ 1.23456 ] [ 1.23456 make-struct-12 ffi_test_36 ] unit-test

FUNCTION: ulonglong ffi_test_38 ( ulonglong x, ulonglong y ) ;

[ t ] [ 31 2^ 32 2^ ffi_test_38 63 2^ = ] unit-test

! Test callbacks

: callback-1 ( -- callback ) "void" { } "cdecl" [ ] alien-callback ;

[ 0 1 ] [ [ callback-1 ] infer [ in>> ] [ out>> ] bi ] unit-test

[ t ] [ callback-1 alien? ] unit-test

: callback_test_1 ( ptr -- ) "void" { } "cdecl" alien-indirect ;

[ ] [ callback-1 callback_test_1 ] unit-test

: callback-2 ( -- callback ) "void" { } "cdecl" [ [ 5 throw ] ignore-errors ] alien-callback ;

[ ] [ callback-2 callback_test_1 ] unit-test

: callback-3 ( -- callback ) "void" { } "cdecl" [ 5 "x" set ] alien-callback ;

[ t ] [
    namestack*
    3 "x" set callback-3 callback_test_1
    namestack* eq?
] unit-test

[ 5 ] [
    [
        3 "x" set callback-3 callback_test_1 "x" get
    ] with-scope
] unit-test

: callback-4 ( -- callback )
    "void" { } "cdecl" [ "Hello world" write ] alien-callback
    gc ;

[ "Hello world" ] [
    [ callback-4 callback_test_1 ] with-string-writer
] unit-test

: callback-5 ( -- callback )
    "void" { } "cdecl" [ gc ] alien-callback ;

[ "testing" ] [
    "testing" callback-5 callback_test_1
] unit-test

: callback-5a ( -- callback )
    "void" { } "cdecl" [ 8000000 f <array> drop ] alien-callback ;

! Hack; if we're on ARM, we probably don't have much RAM, so
! skip this test.
! cpu "arm" = [
!     [ "testing" ] [
!         "testing" callback-5a callback_test_1
!     ] unit-test
! ] unless

: callback-6 ( -- callback )
    "void" { } "cdecl" [ [ continue ] callcc0 ] alien-callback ;

[ 1 2 3 ] [ callback-6 callback_test_1 1 2 3 ] unit-test

: callback-7 ( -- callback )
    "void" { } "cdecl" [ 1000000 sleep ] alien-callback ;

[ 1 2 3 ] [ callback-7 callback_test_1 1 2 3 ] unit-test

[ f ] [ namespace global eq? ] unit-test

: callback-8 ( -- callback )
    "void" { } "cdecl" [
        [ continue ] callcc0
    ] alien-callback ;

[ ] [ callback-8 callback_test_1 ] unit-test

: callback-9 ( -- callback )
    "int" { "int" "int" "int" } "cdecl" [
        + + 1+
    ] alien-callback ;

FUNCTION: void ffi_test_36_point_5 ( ) ;

[ ] [ ffi_test_36_point_5 ] unit-test

FUNCTION: int ffi_test_37 ( void* func ) ;

[ 1 ] [ callback-9 ffi_test_37 ] unit-test

[ 7 ] [ callback-9 ffi_test_37 ] unit-test

C-STRUCT: test_struct_13
{ "float" "x1" }
{ "float" "x2" }
{ "float" "x3" }
{ "float" "x4" }
{ "float" "x5" }
{ "float" "x6" } ;

: make-test-struct-13 ( -- alien )
    "test_struct_13" <c-object>
        1.0 over set-test_struct_13-x1
        2.0 over set-test_struct_13-x2
        3.0 over set-test_struct_13-x3
        4.0 over set-test_struct_13-x4
        5.0 over set-test_struct_13-x5
        6.0 over set-test_struct_13-x6 ;

FUNCTION: int ffi_test_39 ( long a, long b, test_struct_13 s ) ;

[ 21 ] [ 12347 12347 make-test-struct-13 ffi_test_39 ] unit-test

! Joe Groff found this problem
C-STRUCT: double-rect
{ "double" "a" }
{ "double" "b" }
{ "double" "c" }
{ "double" "d" } ;

: <double-rect> ( a b c d -- foo )
    "double-rect" <c-object>
    {
        [ set-double-rect-d ]
        [ set-double-rect-c ]
        [ set-double-rect-b ]
        [ set-double-rect-a ]
        [ ]
    } cleave ;

: >double-rect< ( foo -- a b c d )
    {
        [ double-rect-a ]
        [ double-rect-b ]
        [ double-rect-c ]
        [ double-rect-d ]
    } cleave ;

: double-rect-callback ( -- alien )
    "void" { "void*" "void*" "double-rect" } "cdecl"
    [ "example" set-global 2drop ] alien-callback ;

: double-rect-test ( arg -- arg' )
    f f rot
    double-rect-callback
    "void" { "void*" "void*" "double-rect" } "cdecl" alien-indirect
    "example" get-global ;

[ 1.0 2.0 3.0 4.0 ]
[ 1.0 2.0 3.0 4.0 <double-rect> double-rect-test >double-rect< ] unit-test

C-STRUCT: test_struct_14
{ "double" "x1" }
{ "double" "x2" } ;

FUNCTION: test_struct_14 ffi_test_40 ( double x1, double x2 ) ;

[ 1.0 2.0 ] [
    1.0 2.0 ffi_test_40
    [ test_struct_14-x1 ] [ test_struct_14-x2 ] bi
] unit-test

: callback-10 ( -- callback )
    "test_struct_14" { "double" "double" } "cdecl"
    [
        "test_struct_14" <c-object>
        [ set-test_struct_14-x2 ] keep
        [ set-test_struct_14-x1 ] keep
    ] alien-callback ;

: callback-10-test ( x1 x2 callback -- result )
    "test_struct_14" { "double" "double" } "cdecl" alien-indirect ;

[ 1.0 2.0 ] [
    1.0 2.0 callback-10 callback-10-test
    [ test_struct_14-x1 ] [ test_struct_14-x2 ] bi
] unit-test

FUNCTION: test-struct-12 ffi_test_41 ( int a, double x ) ;

[ 1 2.0 ] [
    1 2.0 ffi_test_41
    [ test-struct-12-a ] [ test-struct-12-x ] bi
] unit-test

: callback-11 ( -- callback )
    "test-struct-12" { "int" "double" } "cdecl"
    [
        "test-struct-12" <c-object>
        [ set-test-struct-12-x ] keep
        [ set-test-struct-12-a ] keep
    ] alien-callback ;

: callback-11-test ( x1 x2 callback -- result )
    "test-struct-12" { "int" "double" } "cdecl" alien-indirect ;

[ 1 2.0 ] [
    1 2.0 callback-11 callback-11-test
    [ test-struct-12-a ] [ test-struct-12-x ] bi
] unit-test

C-STRUCT: test_struct_15
{ "float" "x" }
{ "float" "y" } ;

FUNCTION: test_struct_15 ffi_test_42 ( float x, float y ) ;

[ 1.0 2.0 ] [ 1.0 2.0 ffi_test_42 [ test_struct_15-x ] [ test_struct_15-y ] bi ] unit-test

: callback-12 ( -- callback )
    "test_struct_15" { "float" "float" } "cdecl"
    [
        "test_struct_15" <c-object>
        [ set-test_struct_15-y ] keep
        [ set-test_struct_15-x ] keep
    ] alien-callback ;

: callback-12-test ( x1 x2 callback -- result )
    "test_struct_15" { "float" "float" } "cdecl" alien-indirect ;

[ 1.0 2.0 ] [
    1.0 2.0 callback-12 callback-12-test
    [ test_struct_15-x ] [ test_struct_15-y ] bi
] unit-test

C-STRUCT: test_struct_16
{ "float" "x" }
{ "int" "a" } ;

FUNCTION: test_struct_16 ffi_test_43 ( float x, int a ) ;

[ 1.0 2 ] [ 1.0 2 ffi_test_43 [ test_struct_16-x ] [ test_struct_16-a ] bi ] unit-test

: callback-13 ( -- callback )
    "test_struct_16" { "float" "int" } "cdecl"
    [
        "test_struct_16" <c-object>
        [ set-test_struct_16-a ] keep
        [ set-test_struct_16-x ] keep
    ] alien-callback ;

: callback-13-test ( x1 x2 callback -- result )
    "test_struct_16" { "float" "int" } "cdecl" alien-indirect ;

[ 1.0 2 ] [
    1.0 2 callback-13 callback-13-test
    [ test_struct_16-x ] [ test_struct_16-a ] bi
] unit-test

FUNCTION: test_struct_14 ffi_test_44 ( ) ; inline

[ 1.0 2.0 ] [ ffi_test_44 [ test_struct_14-x1 ] [ test_struct_14-x2 ] bi ] unit-test

: stack-frame-bustage ( -- a b ) ffi_test_44 gc 3 ;

[ ] [ stack-frame-bustage 2drop ] unit-test

FUNCTION: complex-float ffi_test_45 ( int x ) ;

[ C{ 3.0 0.0 } ] [ 3 ffi_test_45 ] unit-test

FUNCTION: complex-double ffi_test_46 ( int x ) ;

[ C{ 3.0 0.0 } ] [ 3 ffi_test_46 ] unit-test

FUNCTION: complex-float ffi_test_47 ( complex-float x, complex-double y ) ;

[ C{ 4.0 4.0 } ] [
    C{ 1.0 2.0 }
    C{ 1.5 1.0 } ffi_test_47
] unit-test
