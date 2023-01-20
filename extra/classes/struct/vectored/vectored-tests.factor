! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct classes.struct.vectored
kernel sequences specialized-arrays tools.test vocabs compiler.units ;
FROM: specialized-arrays.private => specialized-array-vocab ;
SPECIALIZED-ARRAYS: int ushort float ;
IN: classes.struct.vectored.tests

STRUCT: foo
    { x int }
    { y float }
    { z ushort }
    { w ushort } ;

SPECIALIZED-ARRAY: foo
VECTORED-STRUCT: foo

{
    T{ vectored-foo
        { x int-array{    0   1   0   0   } }
        { y float-array{  0.0 2.0 0.0 0.0 } }
        { z ushort-array{ 0   3   0   0   } }
        { w ushort-array{ 0   4   0   0   } }
    }
} [ S{ foo f 1 2.0 3 4 } 4 <vectored-foo> [ set-second ] keep ] unit-test

{
    T{ vectored-foo
        { x int-array{     0    1    2    3   } }
        { y float-array{   0.0  0.5  1.0  1.5 } }
        { z ushort-array{ 10   20   30   40   } }
        { w ushort-array{ 15   25   35   45   } }
    }
} [
    foo-array{
        S{ foo { x 0 } { y 0.0 } { z 10 } { w 15 } }
        S{ foo { x 1 } { y 0.5 } { z 20 } { w 25 } }
        S{ foo { x 2 } { y 1.0 } { z 30 } { w 35 } }
        S{ foo { x 3 } { y 1.5 } { z 40 } { w 45 } }
    } struct-transpose
] unit-test

{
    foo-array{
        S{ foo { x 0 } { y 0.0 } { z 10 } { w 15 } }
        S{ foo { x 1 } { y 0.5 } { z 20 } { w 25 } }
        S{ foo { x 2 } { y 1.0 } { z 30 } { w 35 } }
        S{ foo { x 3 } { y 1.5 } { z 40 } { w 45 } }
    }
} [
    T{ vectored-foo
        { x int-array{     0    1    2    3   } }
        { y float-array{   0.0  0.5  1.0  1.5 } }
        { z ushort-array{ 10   20   30   40   } }
        { w ushort-array{ 15   25   35   45   } }
    } struct-transpose
] unit-test

{ 30 } [
    T{ vectored-foo
        { x int-array{     0    1    2    3   } }
        { y float-array{   0.0  0.5  1.0  1.5 } }
        { z ushort-array{ 10   20   30   40   } }
        { w ushort-array{ 15   25   35   45   } }
    } third z>>
] unit-test

{ S{ foo { x 2 } { y 1.0 } { z 30 } { w 35 } } } [
    T{ vectored-foo
        { x int-array{     0    1    2    3   } }
        { y float-array{   0.0  0.5  1.0  1.5 } }
        { z ushort-array{ 10   20   30   40   } }
        { w ushort-array{ 15   25   35   45   } }
    } third vectored-element>
] unit-test

{ } [
    [
        foo specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test
