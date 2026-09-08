USING: accessors alien.data arrays cpu.arm.64.features kernel
math math.bitwise math.vectors math.vectors.conversion
math.vectors.simd math.vectors.simd.extensions namespaces random
sequences tools.test tools.test.fuzz ;
IN: math.vectors.simd.extensions.tests

<PRIVATE
: same-dispatch? ( quot: ( -- vector ) -- ? )
    [ call underlying>> ]
    [ optional-arm64-features disabled-arm64-features
      [ call underlying>> ] with-variable ] bi = ; inline
: random-half ( -- vector )
    8 [ 65536 random ] replicate >ushort-8 half-8-cast ;
: random-bfloat ( -- vector )
    8 [ 65536 random ] replicate >ushort-8 bfloat-8-cast ;
: random-float ( -- vector )
    4 [ 0x100000000 random ] replicate >uint-4 float-4-cast ;
:: half-trial ( a b c -- ? )
    [ a b v+ ] same-dispatch?
    [ a b v- ] same-dispatch? and
    [ a b v* ] same-dispatch? and
    [ a b v/ ] same-dispatch? and
    [ a vsqrt ] same-dispatch? and
    [ a b c vfma ] same-dispatch? and
    [ a b vmin ] same-dispatch? and
    [ a b vmax ] same-dispatch? and
    [ a b v= ] same-dispatch? and
    [ a b v< ] same-dispatch? and
    [ a b v<= ] same-dispatch? and
    [ a b v> ] same-dispatch? and
    [ a b v>= ] same-dispatch? and
    [ a b vunordered? ] same-dispatch? and ;
:: bfloat-trial ( a b c -- ? )
    [ a b c vbdot2+ ] same-dispatch?
    [ a b c vbmatmul2x4+ ] same-dispatch? and ;
PRIVATE>

{ half-8{ 1 2 3 4 5 6 7 8 } } [
    half-8{ 1 2 3 4 5 6 7 8 } half-8 <ref> half-8 deref
] unit-test
{ bfloat-8{ 1 2 3 4 5 6 7 8 } } [
    bfloat-8{ 1 2 3 4 5 6 7 8 } bfloat-8 <ref> bfloat-8 deref
] unit-test
{ ushort-8{ 65535 0 65535 0 65535 0 65535 0 } } [
    half-8{ t f t f t f t f } ushort-8-cast
] unit-test
{ ushort-8{ 65535 0 0 65535 0 0 65535 0 } } [
    half-8{ 1 2 3 4 5 6 7 8 } half-8{ 1 3 2 4 6 5 7 9 } v= ushort-8-cast
] unit-test
{ 4 } [ half-8{ t f t f t f t f } vcount ] unit-test

! SIMD square root returns a NaN for negative lanes, including when optional
! FP16 instructions are disabled. Scalar sqrt would produce a complex value.
{ ushort-8{ 0x7e00 0x7e00 0x8000 0 0x4000 0x7c00 0x7e00 0x1c00 } } [
    half-8{ -1 -1/0. -0.0 0.0 4 1/0. 0/0. 0.0000152587890625 }
    vsqrt ushort-8-cast
] unit-test
{ ushort-8{ 0x7e00 0x7e00 0x8000 0 0x4000 0x7c00 0x7e00 0x1c00 } } [
    optional-arm64-features disabled-arm64-features [
        half-8{ -1 -1/0. -0.0 0.0 4 1/0. 0/0. 0.0000152587890625 }
        vsqrt ushort-8-cast
    ] with-variable
] unit-test
{ ushort-8{ 0x7fc0 0x7fc0 0x8000 0 0x4000 0x7f80 0x7fc0 0x3b80 } } [
    bfloat-8{ -1 -1/0. -0.0 0.0 4 1/0. 0/0. 0.0000152587890625 }
    vsqrt ushort-8-cast
] unit-test

! These expectations run on fallback-only hosts as well as optional FP16
! kernels. Random pairs rarely exercise signed zeros or a NaN in each order.
{ ushort-8{ 0x8000 0x8000 0x3c00 0x3c00 0xbc00 0x7e00 0xfc00 0xfc00 } } [
    half-8{ 0.0 -0.0 1.0 0/0. -1.0 0/0. 1/0. -1/0. }
    half-8{ -0.0 0.0 0/0. 1.0 0/0. 0/0. -1/0. 1/0. }
    vmin ushort-8-cast
] unit-test
{ ushort-8{ 0 0 0x3c00 0x3c00 0xbc00 0x7e00 0x7c00 0x7c00 } } [
    half-8{ 0.0 -0.0 1.0 0/0. -1.0 0/0. 1/0. -1/0. }
    half-8{ -0.0 0.0 0/0. 1.0 0/0. 0/0. -1/0. 1/0. }
    vmax ushort-8-cast
] unit-test

{ half-8{ 5 6 7 8 1 2 3 4 } } [
    half-8{ 1 2 3 4 5 6 7 8 } { 4 5 6 7 0 1 2 3 } vshuffle-elements
] unit-test

{ half-8{ 1 2 3 4 5 6 7 8 } } [
    float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } float-4 half-8 vconvert
] unit-test
{ float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } } [
    half-8{ 1 2 3 4 5 6 7 8 } half-8 float-4 vconvert
] unit-test
{ bfloat-8{ 1 2 3 4 5 6 7 8 } } [
    float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } float-4 bfloat-8 vconvert
] unit-test
{ float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } } [
    bfloat-8{ 1 2 3 4 5 6 7 8 } bfloat-8 float-4 vconvert
] unit-test
{ bfloat-8{ 1 2 3 4 5 6 7 8 } } [
    half-8{ 1 2 3 4 5 6 7 8 } half-8 bfloat-8 vconvert
] unit-test

{ int-4{ 30 174 446 846 } } [
    char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
    dup 0 int-4-with vdot4+
] unit-test
{ uint-4{ 260100 260100 260100 260100 } } [
    255 uchar-16-with dup 0 uint-4-with vdot4+
] unit-test
{ int-4{ -130560 -130560 -130560 -130560 } } [
    255 uchar-16-with -128 char-16-with 0 int-4-with vdot4+
] unit-test
{ int-4{ -130560 -130560 -130560 -130560 } } [
    -128 char-16-with 255 uchar-16-with 0 int-4-with vdot4+
] unit-test
{ int-4{ 205 494 494 1295 } } [
    char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
    char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
    int-4{ 1 2 2 3 } vmatmul2x8+
] unit-test
{ float-4{ 5 25 61 113 } } [
    bfloat-8{ 1 2 3 4 5 6 7 8 } dup 0 float-4-with vbdot2+
] unit-test
{ float-4{ 30 70 70 174 } } [
    bfloat-8{ 1 2 3 4 5 6 7 8 } dup 0 float-4-with vbmatmul2x4+
] unit-test

! Differential checks compare bytes, so signs of zero and NaN canonicalization
! are covered as well as ordinary values. They also run on fallback-only hosts.
[ random-half random-half random-half ] [ half-trial ] fuzz-test
[ random-bfloat random-bfloat random-float ] [ bfloat-trial ] fuzz-test
[ random-float random-float ] [ [ v>half ] 2curry same-dispatch? ] fuzz-test
[ random-float random-float ] [ [ v>bfloat ] 2curry same-dispatch? ] fuzz-test
{ t } [
    [ 255 uchar-16-with -128 char-16-with 0 int-4-with vmatmul2x8+ ] same-dispatch?
] unit-test

[ 1 half-8-with 1 half-8-with 0 int-4-with vdot4+ ] must-fail
[ 1 uchar-16-with 1 uchar-16-with 0 int-4-with vdot4+ ] must-fail
[ { 1 2 3 } >half-8 ] must-fail
