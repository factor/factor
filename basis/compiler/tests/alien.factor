USING: accessors alien alien.c-types alien.complex alien.data alien.libraries
alien.syntax arrays byte-arrays classes classes.struct combinators
combinators.extras compiler compiler.test concurrency.promises continuations
destructors effects generalizations io io.backend io.pathnames
io.streams.string kernel kernel.private libc layouts locals math math.bitwise
math.private memory namespaces namespaces.private random parser quotations
sequences slots.private specialized-arrays stack-checker stack-checker.errors
system threads tools.test words ;
FROM: alien.c-types => float short ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: char
IN: compiler.tests.alien

! Make sure that invalid inputs don't pass the stack checker
[ [ void { } "cdecl" alien-indirect ] infer ] must-fail
[ [ "void" { } cdecl alien-indirect ] infer ] must-fail
[ [ void* 3 cdecl alien-indirect ] infer ] must-fail
[ [ void* { "int" } cdecl alien-indirect ] infer ] must-fail
[ [ void* { int } cdecl { } alien-callback ] infer ] must-fail

<<
: libfactor-ffi-tests-path ( -- string )
    "resource:" absolute-path
    {
        { [ os windows? ]  [ "libfactor-ffi-test.dll" ] }
        { [ os macos? ] [ "libfactor-ffi-test.dylib" ] }
        { [ os unix?  ]  [ "libfactor-ffi-test.so" ] }
    } cond append-path ;

: mingw? ( -- ? ) os windows? vm-compiler "GCC" head? and ;

"f-cdecl" libfactor-ffi-tests-path mingw? mingw cdecl ? add-library

"f-stdcall" libfactor-ffi-tests-path stdcall add-library

"f-fastcall" libfactor-ffi-tests-path fastcall add-library
>>

LIBRARY: f-cdecl

FUNCTION: void ffi_test_0 ( )
{ } [ ffi_test_0 ] unit-test

FUNCTION: int ffi_test_1 ( )
{ 3 } [ ffi_test_1 ] unit-test

{ } [ \ ffi_test_1 def>> [ drop ] append compile-call ] unit-test

FUNCTION: int ffi_test_2 ( int x, int y )
{ 5 } [ 2 3 ffi_test_2 ] unit-test
[ "hi" 3 ffi_test_2 ] must-fail

FUNCTION: int ffi_test_3 ( int x, int y, int z, int t )
{ 25 } [ 2 3 4 5 ffi_test_3 ] unit-test

FUNCTION: float ffi_test_4 ( )
{ 1.5 } [ ffi_test_4 ] unit-test

FUNCTION: double ffi_test_5 ( )
{ 1.5 } [ ffi_test_5 ] unit-test

FUNCTION: int ffi_test_9 ( int a, int b, int c, int d, int e, int f, int g )
{ 28 } [ 1 2 3 4 5 6 7 ffi_test_9 ] unit-test
[ "a" 2 3 4 5 6 7 ffi_test_9 ] must-fail
[ 1 2 3 4 5 6 "a" ffi_test_9 ] must-fail

STRUCT: FOO { x int } { y int } ;

: make-FOO ( x y -- FOO )
    FOO <struct> swap >>y swap >>x ;

FUNCTION: int ffi_test_11 ( int a, FOO b, int c )

{ 14 } [ 1 2 3 make-FOO 4 ffi_test_11 ] unit-test

FUNCTION: int ffi_test_13 ( int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k )

{ 66 } [ 1 2 3 4 5 6 7 8 9 10 11 ffi_test_13 ] unit-test

FUNCTION: FOO ffi_test_14 ( int x, int y )

{ 11 6 } [ 11 6 ffi_test_14 [ x>> ] [ y>> ] bi ] unit-test

FUNCTION: c-string ffi_test_15 ( c-string x, c-string y )

{ "foo" } [ "xy" "zt" ffi_test_15 ] unit-test
{ "bar" } [ "xy" "xy" ffi_test_15 ] unit-test
[ 1 2 ffi_test_15 ] must-fail

STRUCT: BAR { x long } { y long } { z long } ;

FUNCTION: BAR ffi_test_16 ( long x, long y, long z )

{ 11 6 -7 } [
    11 6 -7 ffi_test_16 [ x>> ] [ y>> ] [ z>> ] tri
] unit-test

STRUCT: TINY { x int } ;

FUNCTION: TINY ffi_test_17 ( int x )

{ 11 } [ 11 ffi_test_17 x>> ] unit-test

[ [ alien-indirect ] infer ] [ inference-error? ] must-fail-with

: indirect-test-1 ( ptr -- result )
    int { } cdecl alien-indirect ;

{ 1 1 } [ indirect-test-1 ] must-infer-as

{ 3 } [ &: ffi_test_1 indirect-test-1 ] unit-test

: indirect-test-1' ( ptr -- )
    int { } cdecl alien-indirect drop ;

{ 1 0 } [ indirect-test-1' ] must-infer-as

{ } [ &: ffi_test_1 indirect-test-1' ] unit-test

[ -1 indirect-test-1 ] must-fail

: indirect-test-2 ( x y ptr -- result )
    int { int int } cdecl alien-indirect gc ;

{ 3 1 } [ indirect-test-2 ] must-infer-as

{ 5 } [ 2 3 &: ffi_test_2 indirect-test-2 ] unit-test

: indirect-test-3 ( a b c d ptr -- result )
    int { int int int int } stdcall alien-indirect
    gc ;

{ f } [ "f-stdcall" library-dll f = ] unit-test
{ stdcall } [ "f-stdcall" lookup-library abi>> ] unit-test

: ffi_test_18 ( w x y z -- int )
    int "f-stdcall" "ffi_test_18" { int int int int } f
    alien-invoke gc ;

{ 25 } [ 2 3 4 5 ffi_test_18 ] unit-test

: ffi_test_19 ( x y z -- BAR )
    BAR "f-stdcall" "ffi_test_19" { long long long } f
    alien-invoke gc ;

{ 11 6 -7 } [
    11 6 -7 ffi_test_19 [ x>> ] [ y>> ] [ z>> ] tri
] unit-test

: multi_ffi_test_18 ( w x y z w' x' y' z' -- int int )
    [ int "f-stdcall" "ffi_test_18" { int int int int } f alien-invoke ]
    4dip
    int "f-stdcall" "ffi_test_18" { int int int int } f alien-invoke
    gc ;

{ 25 85 } [ 2 3 4 5 6 7 8 9 multi_ffi_test_18 ] unit-test

FUNCTION: double ffi_test_6 ( float x, float y )
{ 6.0 } [ 3.0 2.0 ffi_test_6 ] unit-test
[ "a" "b" ffi_test_6 ] must-fail

FUNCTION: double ffi_test_7 ( double x, double y )
{ 6.0 } [ 3.0 2.0 ffi_test_7 ] unit-test

FUNCTION: double ffi_test_8 ( double x, float y, double z, float t, int w )
{ 19.0 } [ 3.0 2.0 1.0 6.0 7 ffi_test_8 ] unit-test

FUNCTION: int ffi_test_10 ( int a, int b, double c, int d, float e, int f, int g, int h )
{ -34 } [ 1 2 3.0 4 5.0 6 7 8 ffi_test_10 ] unit-test

FUNCTION: void ffi_test_20 ( double x1, double x2, double x3,
    double y1, double y2, double y3,
    double z1, double z2, double z3 )

{ } [ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 ffi_test_20 ] unit-test

! Make sure XT doesn't get clobbered in stack frame

: ffi_test_31 ( a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a -- result y )
    int
    "f-cdecl" "ffi_test_31"
    { int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int int } f
    alien-invoke gc 3 ;

{ 861 3 } [ 42 [ ] each-integer ffi_test_31 ] unit-test

: ffi_test_31_point_5 ( a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a -- result )
    float
    "f-cdecl" "ffi_test_31_point_5"
    { float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float float } f
    alien-invoke ;

{ 861.0 } [ 42 [ >float ] each-integer ffi_test_31_point_5 ] unit-test

FUNCTION: longlong ffi_test_21 ( long x, long y )

{ 121932631112635269 } [ 123456789 987654321 ffi_test_21 ] unit-test

FUNCTION: long ffi_test_22 ( long x, longlong y, longlong z )

{ 987655432 } [ 1111 121932631112635269 123456789 ffi_test_22 ] unit-test

[ 1111 f 123456789 ffi_test_22 ] must-fail

STRUCT: RECT
    { x float } { y float }
    { w float } { h float } ;

: <RECT> ( x y w h -- rect )
    RECT <struct>
        swap >>h
        swap >>w
        swap >>y
        swap >>x ;

FUNCTION: int ffi_test_12 ( int a, int b, RECT c, int d, int e, int f )

{ 45 } [ 1 2 3.0 4.0 5.0 6.0 <RECT> 7 8 9 ffi_test_12 ] unit-test

[ 1 2 { 1 2 3 } 7 8 9 ffi_test_12 ] must-fail

FUNCTION: float ffi_test_23 ( float[3] x, float[3] y )

{ 32.0 } [
    { 1.0 2.0 3.0 } float >c-array
    { 4.0 5.0 6.0 } float >c-array
    ffi_test_23
] unit-test

! Test odd-size structs
STRUCT: test-struct-1 { x char[1] } ;

FUNCTION: test-struct-1 ffi_test_24 ( )

{ S{ test-struct-1 { x char-array{ 1 } } } } [ ffi_test_24 ] unit-test

STRUCT: test-struct-2 { x char[2] } ;

FUNCTION: test-struct-2 ffi_test_25 ( )

{ S{ test-struct-2 { x char-array{ 1 2 } } } } [ ffi_test_25 ] unit-test

STRUCT: test-struct-3 { x char[3] } ;

FUNCTION: test-struct-3 ffi_test_26 ( )

{ S{ test-struct-3 { x char-array{ 1 2 3 } } } } [ ffi_test_26 ] unit-test

STRUCT: test-struct-4 { x char[4] } ;

FUNCTION: test-struct-4 ffi_test_27 ( )

{ S{ test-struct-4 { x char-array{ 1 2 3 4 } } } } [ ffi_test_27 ] unit-test

STRUCT: test-struct-5 { x char[5] } ;

FUNCTION: test-struct-5 ffi_test_28 ( )

{ S{ test-struct-5 { x char-array{ 1 2 3 4 5 } } } } [ ffi_test_28 ] unit-test

STRUCT: test-struct-6 { x char[6] } ;

FUNCTION: test-struct-6 ffi_test_29 ( )

{ S{ test-struct-6 { x char-array{ 1 2 3 4 5 6 } } } } [ ffi_test_29 ] unit-test

STRUCT: test-struct-7 { x char[7] } ;

FUNCTION: test-struct-7 ffi_test_30 ( )

{ S{ test-struct-7 { x char-array{ 1 2 3 4 5 6 7 } } } } [ ffi_test_30 ] unit-test

STRUCT: test-struct-8 { x double } { y double } ;

FUNCTION: double ffi_test_32 ( test-struct-8 x, int y )

{ 9.0 } [
    test-struct-8 <struct>
    1.0 >>x
    2.0 >>y
    3 ffi_test_32
] unit-test

STRUCT: test-struct-9 { x float } { y float } ;

FUNCTION: double ffi_test_33 ( test-struct-9 x, int y )

{ 9.0 } [
    test-struct-9 <struct>
    1.0 >>x
    2.0 >>y
    3 ffi_test_33
] unit-test

STRUCT: test-struct-10 { x float } { y int } ;

FUNCTION: double ffi_test_34 ( test-struct-10 x, int y )

{ 9.0 } [
    test-struct-10 <struct>
    1.0 >>x
    2 >>y
    3 ffi_test_34
] unit-test

STRUCT: test-struct-11 { x int } { y int } ;

FUNCTION: double ffi_test_35 ( test-struct-11 x, int y )

{ 9.0 } [
    test-struct-11 <struct>
    1 >>x
    2 >>y
    3 ffi_test_35
] unit-test

STRUCT: test-struct-12 { a int } { x double } ;

: make-struct-12 ( x -- alien )
    test-struct-12 <struct>
        swap >>x ;

FUNCTION: double ffi_test_36 ( test-struct-12 x )

{ 1.23456 } [ 1.23456 make-struct-12 ffi_test_36 ] unit-test

FUNCTION: ulonglong ffi_test_38 ( ulonglong x, ulonglong y )

{ t } [ 31 2^ 32 2^ ffi_test_38 63 2^ = ] unit-test

! Test callbacks
: callback-throws ( -- x )
    int { } cdecl [ "Hi" throw ] alien-callback ;

{ t } [
    callback-throws [ alien? ] with-callback
] unit-test

: callback-1 ( -- callback ) void { } cdecl [ ] alien-callback ;

{ 0 1 } [ [ callback-1 ] infer [ in>> length ] [ out>> length ] bi ] unit-test

{ t } [ callback-1 [ alien? ] with-callback ] unit-test

: callback_test_1 ( ptr -- ) void { } cdecl alien-indirect ;

{ } [ callback-1 [ callback_test_1 ] with-callback ] unit-test

: callback-2 ( -- callback ) void { } cdecl [ [ 5 throw ] ignore-errors ] alien-callback ;

{ } [ callback-2 [ callback_test_1 ] with-callback ] unit-test

: callback-3 ( -- callback ) void { } cdecl [ 5 "x" set ] alien-callback ;

{ t 3 5 } [
    [
        (get-namestack)
        3 "x" set callback-3 [ callback_test_1 ] with-callback
        (get-namestack) eq?
        "x" get "x" get-global
    ] with-scope
] unit-test

: callback-5 ( -- callback )
    void { } cdecl [ gc ] alien-callback ;

{ "testing" } [
    "testing" callback-5 [ callback_test_1 ] with-callback
] unit-test

: callback-5b ( -- callback )
    void { } cdecl [ compact-gc ] alien-callback ;

{ "testing" } [
    "testing" callback-5b [ callback_test_1 ] with-callback
] unit-test

: callback-6 ( -- callback )
    void { } cdecl [ [ continue ] callcc0 ] alien-callback ;

{ 1 2 3 } [
    callback-6 [ callback_test_1 1 2 3 ] with-callback
] unit-test

: callback-7 ( -- callback )
    void { } cdecl [ 1000000 sleep ] alien-callback ;

{ 1 2 3 } [ callback-7 [ callback_test_1 1 2 3 ] with-callback ] unit-test

{ f } [ namespace global eq? ] unit-test

: callback-8 ( -- callback )
    void { } cdecl [ [ ] in-thread yield ] alien-callback ;

{ } [ callback-8 [ callback_test_1 ] with-callback ] unit-test

: callback-9 ( -- callback )
    int { int int int } cdecl [
        + + 1 +
    ] alien-callback ;

FUNCTION: void ffi_test_36_point_5 ( )

{ } [ ffi_test_36_point_5 ] unit-test

FUNCTION: int ffi_test_37 ( void* func )

{ 1 } [ callback-9 [ ffi_test_37 ] with-callback ] unit-test

{ 7 } [ callback-9 [ ffi_test_37 ] with-callback ] unit-test

STRUCT: test_struct_13
    { x1 float }
    { x2 float }
    { x3 float }
    { x4 float }
    { x5 float }
    { x6 float } ;

: make-test-struct-13 ( -- alien )
    test_struct_13 <struct>
        1.0 >>x1
        2.0 >>x2
        3.0 >>x3
        4.0 >>x4
        5.0 >>x5
        6.0 >>x6 ;

FUNCTION: int ffi_test_39 ( long a, long b, test_struct_13 s )

{ 21 } [ 12347 12347 make-test-struct-13 ffi_test_39 ] unit-test

! Joe Groff found this problem
STRUCT: double-rect
    { a double }
    { b double }
    { c double }
    { d double } ;

: <double-rect> ( a b c d -- foo )
    double-rect <struct>
        swap >>d
        swap >>c
        swap >>b
        swap >>a ;

: >double-rect< ( foo -- a b c d )
    {
        [ a>> ]
        [ b>> ]
        [ c>> ]
        [ d>> ]
    } cleave ;

: double-rect-callback ( -- alien )
    void { void* void* double-rect } cdecl
    [ "example" set-global 2drop ] alien-callback ;

: double-rect-test ( arg callback -- arg' )
    [ f f ] 2dip
    void { void* void* double-rect } cdecl alien-indirect
    "example" get-global ;

{ byte-array 1.0 2.0 3.0 4.0 } [
    1.0 2.0 3.0 4.0 <double-rect>
    double-rect-callback [
        double-rect-test
        [ >c-ptr class-of ] [ >double-rect< ] bi
    ] with-callback
] unit-test

STRUCT: test_struct_14
    { x1 double }
    { x2 double } ;

FUNCTION: test_struct_14 ffi_test_40 ( double x1, double x2 )

{ 1.0 2.0 } [
    1.0 2.0 ffi_test_40 [ x1>> ] [ x2>> ] bi
] unit-test

: callback-10 ( -- callback )
    test_struct_14 { double double } cdecl
    [
        test_struct_14 <struct>
            swap >>x2
            swap >>x1
    ] alien-callback ;

: callback-10-test ( x1 x2 callback -- result )
    test_struct_14 { double double } cdecl alien-indirect ;

{ 1.0 2.0 } [
    1.0 2.0 callback-10 [
        callback-10-test [ x1>> ] [ x2>> ] bi
    ] with-callback
] unit-test

FUNCTION: test-struct-12 ffi_test_41 ( int a, double x )

{ 1 2.0 } [
    1 2.0 ffi_test_41
    [ a>> ] [ x>> ] bi
] unit-test

: callback-11 ( -- callback )
    test-struct-12 { int double } cdecl
    [
        test-struct-12 <struct>
            swap >>x
            swap >>a
    ] alien-callback ;

: callback-11-test ( x1 x2 callback -- result )
    test-struct-12 { int double } cdecl alien-indirect ;

{ 1 2.0 } [
    1 2.0 callback-11 [
        callback-11-test [ a>> ] [ x>> ] bi
    ] with-callback
] unit-test

STRUCT: test_struct_15
    { x float }
    { y float } ;

FUNCTION: test_struct_15 ffi_test_42 ( float x, float y )

{ 1.0 2.0 } [ 1.0 2.0 ffi_test_42 [ x>> ] [ y>> ] bi ] unit-test

: callback-12 ( -- callback )
    test_struct_15 { float float } cdecl
    [
        test_struct_15 <struct>
            swap >>y
            swap >>x
    ] alien-callback ;

: callback-12-test ( x1 x2 callback -- result )
    test_struct_15 { float float } cdecl alien-indirect ;

{ 1.0 2.0 } [
    1.0 2.0 callback-12 [
        callback-12-test [ x>> ] [ y>> ] bi
    ] with-callback
] unit-test

STRUCT: test_struct_16
    { x float }
    { a int } ;

FUNCTION: test_struct_16 ffi_test_43 ( float x, int a )

{ 1.0 2 } [ 1.0 2 ffi_test_43 [ x>> ] [ a>> ] bi ] unit-test

: callback-13 ( -- callback )
    test_struct_16 { float int } cdecl
    [
        test_struct_16 <struct>
            swap >>a
            swap >>x
    ] alien-callback ;

: callback-13-test ( x1 x2 callback -- result )
    test_struct_16 { float int } cdecl alien-indirect ;

{ 1.0 2 } [
    1.0 2 callback-13 [
        callback-13-test [ x>> ] [ a>> ] bi
    ] with-callback
] unit-test

FUNCTION: test_struct_14 ffi_test_44 ( ) inline

{ 1.0 2.0 } [ ffi_test_44 [ x1>> ] [ x2>> ] bi ] unit-test

: stack-frame-bustage ( -- a b ) ffi_test_44 gc 3 ;

[ stack-frame-bustage ] must-not-fail

! C99 tests
os windows? [

    FUNCTION: complex-float ffi_test_45 ( int x )

    { C{ 3.0 0.0 } } [ 3 ffi_test_45 ] unit-test

    FUNCTION: complex-double ffi_test_46 ( int x )

    { C{ 3.0 0.0 } } [ 3 ffi_test_46 ] unit-test

    FUNCTION: complex-float ffi_test_47 ( complex-float x, complex-double y )

    { C{ 4.0 4.0 } } [
        C{ 1.0 2.0 }
        C{ 1.5 1.0 } ffi_test_47
    ] unit-test

    ! Reported by jedahu
    STRUCT: bool-field-test
        { name c-string }
        { on bool }
        { parents short } ;

    FUNCTION: short ffi_test_48 ( bool-field-test x )

    { 123 } [
        bool-field-test <struct>
            123 >>parents
        ffi_test_48
    ] unit-test

] unless

! Test interaction between threads and callbacks
: thread-callback-1 ( -- callback )
    int { } cdecl [ yield 100 ] alien-callback ;

: thread-callback-2 ( -- callback )
    int { } cdecl [ yield 200 ] alien-callback ;

: thread-callback-invoker ( callback -- n )
    int { } cdecl alien-indirect ;

<promise> "p" set
[
    thread-callback-1 [
        thread-callback-invoker
    ] with-callback "p" get fulfill
] in-thread
{ 200 } [
    thread-callback-2 [ thread-callback-invoker ] with-callback
] unit-test
{ 100 } [ "p" get ?promise ] unit-test

! More alien-assembly tests are in cpu.* vocabs
: assembly-test-1 ( -- ) void { } cdecl [ ] alien-assembly ;

{ } [ assembly-test-1 ] unit-test

{ f } [ "f-fastcall" library-dll f = ] unit-test
{ fastcall } [ "f-fastcall" lookup-library abi>> ] unit-test

: ffi_test_49 ( x -- int )
    int "f-fastcall" "ffi_test_49" { int } f
    alien-invoke gc ;
: ffi_test_50 ( x y -- int )
    int "f-fastcall" "ffi_test_50" { int int } f
    alien-invoke gc ;
: ffi_test_51 ( x y z -- int )
    int "f-fastcall" "ffi_test_51" { int int int } f
    alien-invoke gc ;
: multi_ffi_test_51 ( x y z x' y' z' -- int int )
    [ int "f-fastcall" "ffi_test_51" { int int int } f alien-invoke ]
    3dip
    int "f-fastcall" "ffi_test_51" { int int int } f alien-invoke gc ;

{ 4 } [ 3 ffi_test_49 ] unit-test
{ 8 } [ 3 4 ffi_test_50 ] unit-test
{ 13 } [ 3 4 5 ffi_test_51 ] unit-test
{ 13 22 } [ 3 4 5 6 7 8 multi_ffi_test_51 ] unit-test

: ffi_test_52 ( x y z -- int )
    int "f-fastcall" "ffi_test_52" { int float int } f
    alien-invoke gc ;
: ffi_test_53 ( x y z w -- int )
    int "f-fastcall" "ffi_test_53" { int float int int } f
    alien-invoke gc ;
: ffi_test_57 ( x y -- test-struct-11 )
    test-struct-11 "f-fastcall" "ffi_test_57" { int int } f
    alien-invoke gc ;
: ffi_test_58 ( x y z -- test-struct-11 )
    test-struct-11 "f-fastcall" "ffi_test_58" { int int int } f
    alien-invoke gc ;

! Make sure that large longlong/ulonglong are correctly dealt with
FUNCTION: longlong ffi_test_59 ( longlong x )
FUNCTION: ulonglong ffi_test_60 ( ulonglong x )

{ t } [ most-positive-fixnum 1 + [ ffi_test_59 ] keep = ] unit-test
{ t } [ most-positive-fixnum 1 + [ ffi_test_60 ] keep = ] unit-test

{ -1 } [ -1 ffi_test_59 ] unit-test
{ -1 } [ 0xffffffffffffffff ffi_test_59 ] unit-test
{ 0xffffffffffffffff } [ -1 ffi_test_60 ] unit-test
{ 0xffffffffffffffff } [ 0xffffffffffffffff ffi_test_60 ] unit-test

! GCC bugs
mingw? [
    { 13 } [ 3 4.0 5 ffi_test_52 ] unit-test

    { 19 } [ 3 4.0 5 6 ffi_test_53 ] unit-test
] unless

{ S{ test-struct-11 f 7 -1 } } [ 3 4 ffi_test_57 ] unit-test

{ S{ test-struct-11 f 7 -3 } } [ 3 4 7 ffi_test_58 ] unit-test

: fastcall-ii-indirect ( x y ptr -- result )
    int { int int } fastcall alien-indirect ;

: fastcall-iii-indirect ( x y z ptr -- result )
    int { int int int } fastcall alien-indirect ;

: fastcall-ifi-indirect ( x y z ptr -- result )
    int { int float int } fastcall alien-indirect ;

: fastcall-ifii-indirect ( x y z w ptr -- result )
    int { int float int int } fastcall alien-indirect ;

: fastcall-struct-return-ii-indirect ( x y ptr -- result )
    test-struct-11 { int int } fastcall alien-indirect ;

: fastcall-struct-return-iii-indirect ( x y z ptr -- result )
    test-struct-11 { int int int } fastcall alien-indirect ;

{ 8 } [
    3 4 &: ffi_test_50 fastcall-ii-indirect
] unit-test

{ 13 } [
    3 4 5 &: ffi_test_51 fastcall-iii-indirect
] unit-test

mingw? [
    { 13 } [
        3 4.0 5 &: ffi_test_52 fastcall-ifi-indirect
    ] unit-test

    { 19 } [
        3 4.0 5 6 &: ffi_test_53 fastcall-ifii-indirect
    ] unit-test
] unless

{ S{ test-struct-11 f 7 -1 } } [
    3 4 &: ffi_test_57 fastcall-struct-return-ii-indirect
] unit-test

{ S{ test-struct-11 f 7 -3 } } [
    3 4 7 &: ffi_test_58 fastcall-struct-return-iii-indirect
] unit-test

: fastcall-ii-callback ( -- ptr )
    int { int int } fastcall [ + 1 + ] alien-callback ;

: fastcall-iii-callback ( -- ptr )
    int { int int int } fastcall [ + + 1 + ] alien-callback ;

: fastcall-ifi-callback ( -- ptr )
    int { int float int } fastcall
    [ [ >integer ] dip + + 1 + ] alien-callback ;

: fastcall-ifii-callback ( -- ptr )
    int { int float int int } fastcall
    [ [ >integer ] 2dip + + + 1 + ] alien-callback ;

: fastcall-struct-return-ii-callback ( -- ptr )
    test-struct-11 { int int } fastcall
    [ [ + ] [ - ] 2bi test-struct-11 boa ] alien-callback ;

: fastcall-struct-return-iii-callback ( -- ptr )
    test-struct-11 { int int int } fastcall
    [ [ drop + ] [ - nip ] 3bi test-struct-11 boa ] alien-callback ;

{ 8 } [
    3 4 fastcall-ii-callback [ fastcall-ii-indirect ] with-callback
] unit-test

{ 13 } [
    3 4 5 fastcall-iii-callback [ fastcall-iii-indirect ] with-callback
] unit-test

{ 13 } [
    3 4.0 5 fastcall-ifi-callback [ fastcall-ifi-indirect ] with-callback
] unit-test

{ 19 } [
    3 4.0 5 6 fastcall-ifii-callback [ fastcall-ifii-indirect ] with-callback
] unit-test

{ S{ test-struct-11 f 7 -1 } } [
    3 4 fastcall-struct-return-ii-callback [
        fastcall-struct-return-ii-indirect
    ] with-callback
] unit-test

{ S{ test-struct-11 f 7 -3 } } [
    3 4 7 fastcall-struct-return-iii-callback [
        fastcall-struct-return-iii-indirect
    ] with-callback
] unit-test

: x64-regression-1 ( -- c )
    int { int int int int int } cdecl [ + + + + ] alien-callback ;

: x64-regression-2 ( x x x x x c -- y )
    int { int int int int int } cdecl alien-indirect ; inline

{ 661 } [
    100 500 50 10 1 x64-regression-1 [ x64-regression-2 ] with-callback
] unit-test

! Stack allocation
: blah ( -- x ) { RECT } [
    1.5 >>x 2.0 >>y [ x>> ] [ y>> ] bi * >fixnum
] with-scoped-allocation ;

{ 3 } [ blah ] unit-test

: out-param-test-1 ( -- b )
    { int } [ [ 12 ] dip 0 int set-alien-value ] with-out-parameters ;

{ 12 } [ out-param-test-1 ] unit-test

: out-param-test-2 ( -- b )
    { { int initial: 12 } } [ drop ] with-out-parameters ;

{ 12 } [ out-param-test-2 ] unit-test

: out-param-test-3 ( -- x y )
    { { RECT initial: S{ RECT { x 3 } { y 4 } } } } [ drop ]
    with-out-parameters
    [ x>> ] [ y>> ] bi ;

{ 3.0 4.0 } [ out-param-test-3 ] unit-test

: out-param-callback ( -- a )
    void { int pointer: int } cdecl
    [ [ 2 * ] dip 0 int set-alien-value ] alien-callback ;

: out-param-indirect ( a a -- b )
    { int } [
        swap void { int pointer: int } cdecl
        alien-indirect
    ] with-out-parameters ;

{ 12 } [
    6 out-param-callback [ out-param-indirect ] with-callback
] unit-test

! Alias analysis regression
: aa-callback-1 ( -- c )
    double { } cdecl [ 5.0 ] alien-callback ;

: aa-indirect-1 ( c -- x )
    double { } cdecl alien-indirect ; inline

TUPLE: some-tuple x ;

{ T{ some-tuple f 5.0 } } [
    [
        some-tuple new
        aa-callback-1 [
            aa-indirect-1
        ] with-callback >>x
    ] compile-call
] unit-test

! GC maps regression
: anton's-regression ( -- )
    f (free) f (free) ;

{ } [ anton's-regression ] unit-test

os windows? [

    STRUCT: bool-and-ptr
        { b bool }
        { ptr void* } ;

    FUNCTION: bool-and-ptr ffi_test_61 ( )

    ! { S{ bool-and-ptr { b t } { ptr f } } } [ ffi_test_61 ] unit-test
    { t } [ ffi_test_61 bool-and-ptr? ] unit-test
    { { t f } } [ ffi_test_61 [ b>> ] [ ptr>> ] bi 2array ] unit-test

] unless

STRUCT: uint-pair
    { a uint }
    { b uint } ;

FUNCTION: uint-pair ffi_test_62 ( )

{
    S{ uint-pair { a 0xabcdefab } { b 0x12345678 } }
} [ ffi_test_62 ] unit-test

STRUCT: ulonglong-pair
    { a ulonglong }
    { b ulonglong } ;

FUNCTION: ulonglong-pair ffi_test_63 ( )

{
    S{ ulonglong-pair { a 0xabcdefabcdefabcd } { b 0x1234567891234567 } }
} [ ffi_test_63 ] unit-test

FUNCTION: void* bug1021_test_1 ( void* s, int x )

! Sanity test the formula: x sq s +
{ t } [
    10 [ [ 100 random ] twice 2array ] replicate
    [ [ first2 [ <alien> ] dip bug1021_test_1 alien-address ] map ]
    [ [ first2 sq + ] map ] bi =
] unit-test

: each-to100 ( ... quot: ( ... i -- ... ) i -- ... )
    dup 100 < [
        2dup swap (call) 1 + each-to100
    ] [ 2drop ] if ; inline recursive

: run-test ( alien -- seq )
    100 33 <array> tuck
    [
        pick swapd
        bug1021_test_1
        spin 2 fixnum+fast
        set-slot
    ] curry curry 0 each-to100 ;

{ } [
    minor-gc 2000 [
        101 <alien> run-test
        ! If #1021 ever comes back it will blow up here because
        ! alien-address wants an alien not a fixnum.
        [ alien-address ] map drop
    ] times
] unit-test

! Varargs with non-float parameters works.
FUNCTION-ALIAS: do-sum-ints2 int ffi_test_64 ( int n, int a, int b )
FUNCTION-ALIAS: do-sum-ints3 int ffi_test_64 ( int n, int a, int b, int c )

{ 30 60 } [
    2 10 20 do-sum-ints2
    3 10 20 30 do-sum-ints3
] unit-test

! Varargs with non-floats doesn't work on windows
FUNCTION-ALIAS: do-sum-doubles2 double ffi_test_65 ( int n, double a, double b )
FUNCTION-ALIAS: do-sum-doubles3 double ffi_test_65 ( int n, double a, double b, double c )

os windows? [
    { 27.0 22.0 } [
        2 7 20 do-sum-doubles2
        3 5 10 7 do-sum-doubles3
    ] unit-test
] unless

FUNCTION: int bug1021_test_2 ( int a, char* b, void* c )
FUNCTION: void* bug1021_test_3 ( c-string a )

: doit ( a -- d )
    33 1byte-array "bar" bug1021_test_3 bug1021_test_2 ;

{ } [
    10000 [ 0 doit 33 assert= ] times
] unit-test

! Tests for System V AMD64 ABI 
STRUCT: test_struct_66 { mem1 ulong } { mem2 ulong } ;
STRUCT: test_struct_68 { mem1 ulong } { mem2 ulong } { mem3 ulong } ;
STRUCT: test_struct_69 { mem1 float } { mem2 ulong } { mem3 ulong } ;
FUNCTION: ulong ffi_test_66 ( ulong a, ulong b, ulong c, test_struct_66 d, test_struct_66 e )
FUNCTION: ulong ffi_test_67 ( ulong a, ulong b, ulong c, test_struct_66 d, test_struct_66 e ulong _f )
FUNCTION: ulong ffi_test_68 ( ulong a, ulong b, ulong c, test_struct_66 d, test_struct_68 e test_struct_66 _f )
FUNCTION: ulong ffi_test_69 ( ulong a, ulong b, ulong c, test_struct_66 d, test_struct_69 e test_struct_66 _f )
FUNCTION: ulong ffi_test_70 ( test_struct_68 a test_struct_68 b, test_struct_66 c )  

{ 28 } [ 1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_66 f 6 7 } ffi_test_66 ] unit-test

: callback-14 ( -- callback )
    ulong { ulong ulong ulong test_struct_66 test_struct_66 } cdecl
    [| a b c d e |
        a b + c +
        d [ mem1>> + ] [ mem2>> + ] bi
        e [ mem1>> + ] [ mem2>> + ] bi
    ] alien-callback ;

: callback-14-test ( a b c d e callback -- result )
    ulong { ulong ulong ulong test_struct_66 test_struct_66 } cdecl alien-indirect ;

{ 28 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_66 f 6 7 } callback-14 [
        callback-14-test
    ] with-callback
] unit-test

{ 44 } [ 1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_66 f 6 7 } 8 ffi_test_67 ] unit-test

: callback-15 ( -- callback )
    ulong { ulong ulong ulong test_struct_66 test_struct_66 ulong } cdecl
    [| a b c d e _f |
        a b + c +
        d [ mem1>> + ] [ mem2>> + ] bi
        e [ mem1>> + ] [ mem2>> + ] bi
        _f 2 * + 
    ] alien-callback ;

: callback-15-test ( a b c d e _f callback -- result )
    ulong { ulong ulong ulong test_struct_66 test_struct_66 ulong } cdecl alien-indirect ;

{ 44 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_66 f 6 7 } 8 callback-15 [
        callback-15-test
    ] with-callback
] unit-test

{ 55 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_68 f 6 7 8 } S{ test_struct_66 f 9 10 } ffi_test_68
] unit-test

: callback-16 ( -- callback )
    ulong { ulong ulong ulong test_struct_66 test_struct_68 test_struct_66 } cdecl
    [| a b c d e _f |
        a b + c +
        d [ mem1>> + ] [ mem2>> + ] bi
        e [ mem1>> + ] [ mem2>> + ] [ mem3>> + ] tri
        _f [ mem1>> + ] [ mem2>> + ] bi
    ] alien-callback ;

: callback-16-test ( a b c d e _f callback -- result )
    ulong { ulong ulong ulong test_struct_66 test_struct_68 test_struct_66 } cdecl alien-indirect ;

{ 55 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_68 f 6 7 8 } S{ test_struct_66 f 9 10 } callback-16 [
        callback-16-test
    ] with-callback
] unit-test

{ 55 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_69 f 6.0 7 8 } S{ test_struct_66 f 9 10 } ffi_test_69
] unit-test

: callback-17 ( -- callback )
    ulong { ulong ulong ulong test_struct_66 test_struct_69 test_struct_66 } cdecl
    [| a b c d e _f |
        a b + c +
        d [ mem1>> + ] [ mem2>> + ] bi
        e [ mem1>> >integer + ] [ mem2>> + ] [ mem3>> + ] tri
        _f [ mem1>> + ] [ mem2>> + ] bi
    ] alien-callback ;

: callback-17-test ( a b c d e _f callback -- result )
    ulong { ulong ulong ulong test_struct_66 test_struct_69 test_struct_66 } cdecl alien-indirect ;

{ 55 } [
    1 2 3 S{ test_struct_66 f 4 5 } S{ test_struct_69 f 6.0 7 8 } S{ test_struct_66 f 9 10 } callback-17 [
        callback-17-test
    ] with-callback
] unit-test

{ 36 } [
    S{ test_struct_68 f 1 2 3 } S{ test_struct_68 f 4 5 6 } S{ test_struct_66 f 7 8 } ffi_test_70
] unit-test

: callback-18 ( -- callback )
    ulong { test_struct_68 test_struct_68 test_struct_66 } cdecl
    [| a b c |
        a [ mem1>> ] [ mem2>> + ] [ mem3>> + ] tri     
        b [ mem1>> + ] [ mem2>> + ] [ mem3>> + ] tri
        c [ mem1>> + ] [ mem2>> + ] bi
    ] alien-callback ;

: callback-18-test ( a b c callback -- result )
    ulong { test_struct_68 test_struct_68 test_struct_66 } cdecl alien-indirect ;

{ 36 } [
    S{ test_struct_68 f 1 2 3 } S{ test_struct_68 f 4 5 6 } S{ test_struct_66 f 7 8 } callback-18 [
        callback-18-test
    ] with-callback
] unit-test
