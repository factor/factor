USING: cpu.architecture math.vectors.simd
math.vectors.simd.intrinsics accessors math.vectors.simd.alien
kernel classes.struct tools.test compiler sequences byte-arrays
alien math kernel.private specialized-arrays combinators ;
SPECIALIZED-ARRAY: float
IN: math.vectors.simd.alien.tests

! Vector alien intrinsics
[ float-4{ 1 2 3 4 } ] [
    [
        float-4{ 1 2 3 4 }
        underlying>> 0 float-4-rep alien-vector
    ] compile-call float-4 boa
] unit-test

[ B{ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 } ] [
    16 [ 1 ] B{ } replicate-as 16 <byte-array>
    [
        0 [
            { byte-array c-ptr fixnum } declare
            float-4-rep set-alien-vector
        ] compile-call
    ] keep
] unit-test

[ float-array{ 1 2 3 4 } ] [
    [
        float-array{ 1 2 3 4 } underlying>>
        float-array{ 4 3 2 1 } clone
        [ underlying>> 0 float-4-rep set-alien-vector ] keep
    ] compile-call
] unit-test

STRUCT: simd-struct
{ x float-4 }
{ y double-2 }
{ z double-4 }
{ w float-8 } ;

[ t ] [ [ simd-struct <struct> ] compile-call >c-ptr [ 0 = ] all? ] unit-test

[
    float-4{ 1 2 3 4 }
    double-2{ 2 1 }
    double-4{ 4 3 2 1 }
    float-8{ 1 2 3 4 5 6 7 8 }
] [
    simd-struct <struct>
    float-4{ 1 2 3 4 } >>x
    double-2{ 2 1 } >>y
    double-4{ 4 3 2 1 } >>z
    float-8{ 1 2 3 4 5 6 7 8 } >>w
    { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
] unit-test

[
    float-4{ 1 2 3 4 }
    double-2{ 2 1 }
    double-4{ 4 3 2 1 }
    float-8{ 1 2 3 4 5 6 7 8 }
] [
    [
        simd-struct <struct>
        float-4{ 1 2 3 4 } >>x
        double-2{ 2 1 } >>y
        double-4{ 4 3 2 1 } >>z
        float-8{ 1 2 3 4 5 6 7 8 } >>w
        { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
    ] compile-call
] unit-test
