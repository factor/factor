IN: math.vectors.simd.alien.tests
USING: cpu.architecture math.vectors.simd
math.vectors.simd.intrinsics accessors math.vectors.simd.alien
kernel classes.struct tools.test compiler sequences byte-arrays
alien math kernel.private specialized-arrays.float ;

! Vector alien intrinsics
[ 4float-array{ 1 2 3 4 } ] [
    [
        4float-array{ 1 2 3 4 }
        underlying>> 0 4float-array-rep alien-vector
    ] compile-call 4float-array boa
] unit-test

[ B{ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 } ] [
    16 [ 1 ] B{ } replicate-as 16 <byte-array>
    [
        0 [
            { byte-array c-ptr fixnum } declare
            4float-array-rep set-alien-vector
        ] compile-call
    ] keep
] unit-test

[ float-array{ 1 2 3 4 } ] [
    [
        float-array{ 1 2 3 4 } underlying>>
        float-array{ 4 3 2 1 } clone
        [ underlying>> 0 4float-array-rep set-alien-vector ] keep
    ] compile-call
] unit-test

STRUCT: simd-struct
{ x 4float-array }
{ y 2double-array }
{ z 4double-array } ;

[ t ] [ [ simd-struct <struct> ] compile-call >c-ptr [ 0 = ] all? ] unit-test

[ 4float-array{ 1 2 3 4 } 2double-array{ 2 1 } 4double-array{ 4 3 2 1 } ] [
    simd-struct <struct>
    4float-array{ 1 2 3 4 } >>x
    2double-array{ 2 1 } >>y
    4double-array{ 4 3 2 1 } >>z
    [ x>> ] [ y>> ] [ z>> ] tri
] unit-test

[ 4float-array{ 1 2 3 4 } 2double-array{ 2 1 } 4double-array{ 4 3 2 1 } ] [
    [
        simd-struct <struct>
        4float-array{ 1 2 3 4 } >>x
        2double-array{ 2 1 } >>y
        4double-array{ 4 3 2 1 } >>z
        [ x>> ] [ y>> ] [ z>> ] tri
    ] compile-call
] unit-test
