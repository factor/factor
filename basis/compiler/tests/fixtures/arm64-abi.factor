! Independent native C callers/callees live in vm/ffi_test_arm64.c.
USING: alien alien.c-types alien.libraries alien.syntax combinators destructors io.pathnames kernel locals math system tools.test tools.test.ffi namespaces ;
FROM: alien.c-types => float ;
IN: compiler.tests.alien-arm64-abi

<< "gap-abi" "resource:" absolute-path
os macos? [ "libfactor-ffi-test.dylib" ] [ "libfactor-ffi-test.so" ] if
append-path cdecl add-library >>

0 general-abi-cases set-global
LIBRARY: gap-abi
FUNCTION: double abi_narrow ( longlong a0, longlong a1, longlong a2, longlong a3, longlong a4, longlong a5, longlong a6, longlong a7, char a8, uchar a9, short a10, ushort a11, int a12, uint a13, longlong a14 )
FUNCTION: double call_narrow ( void* cb )
{ 40147957488.0 } [ 1 2 3 4 5 6 7 8 -9 250 -300 60000 -70000 3000000000 -123456789 abi_narrow general-abi-case ] unit-test
: indirect-narrow ( a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 ptr -- result ) double { longlong longlong longlong longlong longlong longlong longlong longlong char uchar short ushort int uint longlong } cdecl alien-indirect ;
{ 40147957488.0 } [ 1 2 3 4 5 6 7 8 -9 250 -300 60000 -70000 3000000000 -123456789 "abi_narrow" "gap-abi" library-dll dlsym indirect-narrow general-abi-case ] unit-test
: callback-narrow ( -- cb ) double { longlong longlong longlong longlong longlong longlong longlong longlong char uchar short ushort int uint longlong } cdecl [| a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 | a0 1 * a1 2 * + a2 3 * + a3 4 * + a4 5 * + a5 6 * + a6 7 * + a7 8 * + a8 9 * + a9 10 * + a10 11 * + a11 12 * + a12 13 * + a13 14 * + a14 15 * + >float ] alien-callback ;
{ 40147957488.0 } [ callback-narrow [ call_narrow ] with-callback general-abi-case ] unit-test
FUNCTION: double abi_floats ( float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10 )
FUNCTION: double call_floats ( void* cb )
{ 506.0 } [ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 abi_floats general-abi-case ] unit-test
: indirect-floats ( a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 ptr -- result ) double { float float float float float float float float float float float } cdecl alien-indirect ;
{ 506.0 } [ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 "abi_floats" "gap-abi" library-dll dlsym indirect-floats general-abi-case ] unit-test
: callback-floats ( -- cb ) double { float float float float float float float float float float float } cdecl [| a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 | a0 1 * a1 2 * + a2 3 * + a3 4 * + a4 5 * + a5 6 * + a6 7 * + a7 8 * + a8 9 * + a9 10 * + a10 11 * + >float ] alien-callback ;
{ 506.0 } [ callback-floats [ call_floats ] with-callback general-abi-case ] unit-test
FUNCTION: double abi_mixed ( longlong a0, longlong a1, longlong a2, longlong a3, longlong a4, longlong a5, longlong a6, longlong a7, float a8, float a9, float a10, float a11, float a12, float a13, float a14, float a15, char a16, float a17, short a18, double a19, int a20 )
FUNCTION: double call_mixed ( void* cb )
{ -2610657.0 } [ 1 2 3 4 5 6 7 8 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 -9 9.5 -1000 10.25 -123456 abi_mixed general-abi-case ] unit-test
: indirect-mixed ( a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 ptr -- result ) double { longlong longlong longlong longlong longlong longlong longlong longlong float float float float float float float float char float short double int } cdecl alien-indirect ;
{ -2610657.0 } [ 1 2 3 4 5 6 7 8 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 -9 9.5 -1000 10.25 -123456 "abi_mixed" "gap-abi" library-dll dlsym indirect-mixed general-abi-case ] unit-test
: callback-mixed ( -- cb ) double { longlong longlong longlong longlong longlong longlong longlong longlong float float float float float float float float char float short double int } cdecl [| a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 | a0 1 * a1 2 * + a2 3 * + a3 4 * + a4 5 * + a5 6 * + a6 7 * + a7 8 * + a8 9 * + a9 10 * + a10 11 * + a11 12 * + a12 13 * + a13 14 * + a14 15 * + a15 16 * + a16 17 * + a17 18 * + a18 19 * + a19 20 * + a20 21 * + >float ] alien-callback ;
{ -2610657.0 } [ callback-mixed [ call_mixed ] with-callback general-abi-case ] unit-test
: direct-var ( tag named a b d e -- result ) double "gap-abi" "abi_var" { int double int double longlong int } 2 alien-invoke ;
{ -35.0 } [ 1 2.5 -3 4.25 -5 -4 direct-var general-abi-case ] unit-test
: direct-var-spill ( a b c d e f g h i j k l -- result ) double "gap-abi" "abi_var_spill" { int int int int int int int int int int int double } 10 alien-invoke ;
{ 662.0 } [ 1 2 3 4 5 6 7 8 9 10 11 13.0 direct-var-spill general-abi-case ] unit-test

: indirect-var ( tag named a b d e ptr -- result )
    double { int double int double longlong int } cdecl 2 alien-indirect-varargs ;
{ -35.0 } [ 1 2.5 -3 4.25 -5 -4 "abi_var" "gap-abi" library-dll dlsym indirect-var general-abi-case ] unit-test
: indirect-var-spill ( a b c d e f g h i j k l ptr -- result )
    double { int int int int int int int int int int int double } cdecl 10 alien-indirect-varargs ;
{ 662.0 } [ 1 2 3 4 5 6 7 8 9 10 11 13.0 "abi_var_spill" "gap-abi" library-dll dlsym indirect-var-spill general-abi-case ] unit-test
FUNCTION-ALIAS: syntax-var double abi_var ( int tag, double named, ... char a, float b, longlong d, short e )
{ -35.0 } [ 1 2.5 -3 4.25 -5 -4 syntax-var general-abi-case ] unit-test
USING: accessors classes.struct ;
STRUCT: pair { x float } { y float } ;
: <pair> ( x y -- pair ) pair <struct> swap >>y swap >>x ;
FUNCTION: double abi_var_hfa ( pair named, ... pair p, int i )
{ 55.0 } [ 1.0 2.0 <pair> 3.0 4.0 <pair> 5 abi_var_hfa general-abi-case ] unit-test
: indirect-var-hfa ( named p i ptr -- result ) double { pair pair int } cdecl 1 alien-indirect-varargs ;
{ 55.0 } [ 1.0 2.0 <pair> 3.0 4.0 <pair> 5 "abi_var_hfa" "gap-abi" library-dll dlsym indirect-var-hfa general-abi-case ] unit-test
STRUCT: ints { x int } { y int } ;
: <ints> ( x y -- ints ) ints <struct> swap >>y swap >>x ;
FUNCTION: double abi_struct ( longlong a, longlong b, longlong c, longlong d, longlong e, longlong f, longlong g, longlong h, char i, ints j, char k )
FUNCTION: double call_struct ( void* cb )
{ 47.0 } [ 1 2 3 4 5 6 7 8 -9 10 11 <ints> -12 abi_struct general-abi-case ] unit-test
: struct-callback ( -- cb ) double { longlong longlong longlong longlong longlong longlong longlong longlong char ints char } cdecl [| a b c d e f g h i j k | a b + c + d + e + f + g + h + i + j x>> + j y>> 2 * + k + >float ] alien-callback ;
{ 47.0 } [ struct-callback [ call_struct ] with-callback general-abi-case ] unit-test
FUNCTION: double abi_hfa_boundary ( float a, float b, float c, float d, float e, float f, float g, pair h, float i )
FUNCTION: double call_hfa_boundary ( void* cb )
{ 64.0 } [ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 <pair> 10.0 abi_hfa_boundary general-abi-case ] unit-test
: hfa-callback ( -- cb ) double { float float float float float float float pair float } cdecl [| a b c d e f g h i | a b + c + d + e + f + g + h x>> + h y>> 2 * + i + ] alien-callback ;
{ 64.0 } [ hfa-callback [ call_hfa_boundary ] with-callback general-abi-case ] unit-test
USING: specialized-arrays sequences ;
SPECIALIZED-ARRAY: float
STRUCT: array-hfa { values float[3] } ;
: <array-hfa> ( -- p ) array-hfa <struct> float-array{ 1.0 2.0 3.0 } >>values ;
: array-hfa-values ( p -- a b c ) values>> first3 ;
FUNCTION: array-hfa abi_array_hfa ( array-hfa p )
FUNCTION: double call_array_hfa ( void* cb )
{ 11.0 22.0 33.0 } [ <array-hfa> abi_array_hfa array-hfa-values general-abi-case ] unit-test
: indirect-array ( p ptr -- p' ) array-hfa { array-hfa } cdecl alien-indirect ;
{ 11.0 22.0 33.0 } [ <array-hfa> "abi_array_hfa" "gap-abi" library-dll dlsym indirect-array array-hfa-values general-abi-case ] unit-test
: array-callback ( -- cb ) array-hfa { array-hfa } cdecl [ abi_array_hfa ] alien-callback ;
{ 154.0 } [ array-callback [ call_array_hfa ] with-callback general-abi-case ] unit-test
FUNCTION: double abi_var_array ( int named, ... array-hfa p, double d )
{ 20.0 } [ 1 <array-hfa> 5.0 abi_var_array general-abi-case ] unit-test
STRUCT: longs { x longlong } { y longlong } ;
: <longs> ( x y -- p ) longs <struct> swap >>y swap >>x ;
FUNCTION: double abi_int_boundary ( longlong a, longlong b, longlong c, longlong d, longlong e, longlong f, longlong g, longs h, longlong i )
FUNCTION: double call_int_boundary ( void* cb )
{ 64.0 } [ 1 2 3 4 5 6 7 8 9 <longs> 10 abi_int_boundary general-abi-case ] unit-test
: int-callback ( -- cb ) double { longlong longlong longlong longlong longlong longlong longlong longs longlong } cdecl [| a b c d e f g h i | a b + c + d + e + f + g + h x>> + h y>> 2 * + i + >float ] alien-callback ;
{ 64.0 } [ int-callback [ call_int_boundary ] with-callback general-abi-case ] unit-test
FUNCTION: double abi_hfa_stack ( longlong a, longlong b, longlong c, longlong d, longlong e, longlong f, longlong g, longlong h, float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, char i, pair j, float k )
{ 107.0 } [ 1 2 3 4 5 6 7 8 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 -9 10.0 11.0 <pair> 12.0 abi_hfa_stack general-abi-case ] unit-test

"general" general-abi-cases get report-ffi-coverage
general-abi-cases get 27 >= [ "General ABI coverage incomplete" throw ] unless
