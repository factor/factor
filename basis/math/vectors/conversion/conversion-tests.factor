! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.test continuations generalizations
kernel kernel.private locals math.vectors.conversion math.vectors.simd
sequences stack-checker tools.test sequences.generalizations ;
FROM: alien.c-types => char uchar short ushort int uint longlong ulonglong float double ;
IN: math.vectors.conversion.tests

ERROR: optimized-vconvert-inconsistent
    unoptimized-result
    optimized-result ;

MACRO:: test-vconvert ( from-type to-type -- quot )
    [ from-type to-type vconvert ] :> quot
    quot infer :> effect
    effect in>> length :> inputs
    effect out>> length :> outputs

    inputs from-type <array> :> declaration

    [
        inputs narray
        [ quot with-datastack ]
        [ [ [ declaration declare quot call ] compile-call ] with-datastack ] bi
        2dup = [ optimized-vconvert-inconsistent ] unless
        drop outputs firstn
    ] ;

[ uint-4{ 5 1 2 6 } int-4 float-4 vconvert ]
[ bad-vconvert-input? ] must-fail-with

[ int-4{ 1 2 3 4 } uint-4{ 5 1 2 6 } int-4 short-8 vconvert ]
[ bad-vconvert-input? ] must-fail-with

[ uint-4{ 1 2 3 4 } int-4{ 5 1 2 6 } int-4 short-8 vconvert ]
[ bad-vconvert-input? ] must-fail-with

[ uint-4{ 5 1 2 6 } int-4 longlong-2 vconvert ]
[ bad-vconvert-input? ] must-fail-with

{ float-4{ -5.0 1.0 2.0 6.0 } }
[ int-4{ -5 1 2 6 } int-4 float-4 test-vconvert ] unit-test

{ int-4{ -5 1 2 6 } }
[ float-4{ -5.0 1.0 2.0 6.0 } float-4 int-4 test-vconvert ] unit-test

{ int-4{ -5 1 2 6 } }
[ float-4{ -5.0 1.0 2.3 6.7 } float-4 int-4 test-vconvert ] unit-test

{ double-2{ -5.0 1.0 } }
[ longlong-2{ -5 1 } longlong-2 double-2 test-vconvert ] unit-test

{ longlong-2{ -5 1 } }
[ double-2{ -5.0 1.0 } double-2 longlong-2 test-vconvert ] unit-test

! TODO we should be able to do double->int pack
! [ int-4{ -5 1 12 34 } ]
[ double-2{ -5.0 1.0 } double-2{ 12.0 34.0 } double-2 int-4 test-vconvert ]
[ error>> bad-vconvert? ] must-fail-with

{ float-4{ -1.25 2.0 3.0 -4.0 } }
[ double-2{ -1.25 2.0 } double-2{ 3.0 -4.0 } double-2 float-4 test-vconvert ] unit-test

{ int-4{ -1 2 3 -4 } }
[ longlong-2{ -1 2 } longlong-2{ 3 -4 } longlong-2 int-4 test-vconvert ] unit-test

{ short-8{ -1 2 3 -32768 5 32767 -7 32767 } }
[ int-4{ -1 2 3 -40000 } int-4{ 5 60000 -7 80000 } int-4 short-8 test-vconvert ] unit-test

{ short-8{ -1 2 3 -32768 5 32767 -7 32767 } }
[
    int-4{ -1 2 3 -40000 }
    int-4{ 5 60000 -7 80000 } int-4 short-8 test-vconvert
] unit-test

{ ushort-8{ 0 2 3 0 5 60000 0 65535 } }
[ int-4{ -1 2 3 -40000 } int-4{ 5 60000 -7 80000 } int-4 ushort-8 test-vconvert ] unit-test

{ ushort-8{ 65535 2 3 65535 5 60000 65535 65535 } }
[ uint-4{ -1 2 3 -40000 } uint-4{ 5 60000 -7 80000 } uint-4 ushort-8 test-vconvert ] unit-test

[ uint-4{ -1 2 3 -40000 } uint-4{ 5 60000 -7 80000 } uint-4 short-8 test-vconvert ]
[ error>> bad-vconvert? ] must-fail-with

{ ushort-8{ 0 1 2 3 128 129 130 131 } ushort-8{ 4 5 6 7 132 133 134 135 } }
[
    uchar-16{ 0 1 2 3 128 129 130 131 4 5 6 7 132 133 134 135 }
    uchar-16 ushort-8 test-vconvert
] unit-test

{ double-2{ -1.25 2.0 } double-2{ 3.0 -4.0 } }
[ float-4{ -1.25 2.0 3.0 -4.0 } float-4 double-2 test-vconvert ] unit-test

{ int-4{ -1 2 3 -4 } }
[ int-4{ -1 2 3 -4 } int-4 int-4 test-vconvert ] unit-test

{ longlong-2{ -1 2 } longlong-2{ 3 -4 } }
[ int-4{ -1 2 3 -4 } int-4 longlong-2 test-vconvert ] unit-test

[ int-4{ -1 2 3 -4 } int-4 ulonglong-2 test-vconvert ]
[ error>> bad-vconvert? ] must-fail-with

{ ulonglong-2{ 1 2 } ulonglong-2{ 3 4 } }
[ uint-4{ 1 2 3 4 } uint-4 ulonglong-2 test-vconvert ] unit-test

{ longlong-2{ 1 2 } longlong-2{ 3 4 } }
[ uint-4{ 1 2 3 4 } uint-4 longlong-2 test-vconvert ] unit-test

{ int-4{ 1 2 -3 -4 } int-4{ 5 -6 7 -8 } }
[ short-8{ 1 2 -3 -4 5 -6 7 -8 } short-8 int-4 test-vconvert ] unit-test

{ uint-4{ 1 2 3 4 } uint-4{ 5 6 7 8 } }
[ ushort-8{ 1 2 3 4 5 6 7 8 } ushort-8 uint-4 test-vconvert ] unit-test

{ longlong-2{ 1 2 } longlong-2{ 3 4 } }
[ uint-4{ 1 2 3 4 } uint-4 longlong-2 test-vconvert ] unit-test

! TODO we should be able to do multi-tier pack/unpack
! [ longlong-2{ 1 2 } longlong-2{ 3 4 } longlong-2{ 5 6 } longlong-2{ 7 8 } ]
[ ushort-8{ 1 2 3 4 5 6 7 8 } ushort-8 longlong-2 test-vconvert ]
[ error>> bad-vconvert? ] must-fail-with

! [ ushort-8{ 1 2 3 4 5 6 7 8 } ]
[
    longlong-2{ 1 2 }
    longlong-2{ 3 4 }
    longlong-2{ 5 6 }
    longlong-2{ 7 8 }
    longlong-2 ushort-8 test-vconvert
]
[ error>> bad-vconvert? ] must-fail-with
