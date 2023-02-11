! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: euler.b-rep euler.b-rep.examples euler.b-rep.io.obj
io.streams.string literals math.vectors.simd.cords tools.test ;
IN: euler.b-rep.io.obj.tests

CONSTANT: valid-cube-obj
"v -1.0 -1.0 -1.0
v -1.0 1.0 -1.0
v 1.0 -1.0 -1.0
v 1.0 1.0 -1.0
v -1.0 -1.0 1.0
v -1.0 1.0 1.0
v 1.0 -1.0 1.0
v 1.0 1.0 1.0
f 1 2 4 3
f 5 6 2 1
f 7 8 6 5
f 3 4 8 7
f 2 6 8 4
f 5 1 3 7
"

CONSTANT: valid-cube-obj-relative-indices
"v -1.0 -1.0 -1.0
v -1.0 1.0 -1.0
v 1.0 -1.0 -1.0
v 1.0 1.0 -1.0
f -4 -3 -1 -2
v -1.0 -1.0 1.0
v -1.0 1.0 1.0
v 1.0 -1.0 1.0
v 1.0 1.0 1.0
f -4 -3 -7 -8
f 7 8 6 5
f 3 4 8 7
f 2 6 8 4
f 5 1 3 7
"

CONSTANT: valid-cube-obj-texcoords
"# comment should be ignored
v -1.0 -1.0 -1.0
v -1.0 1.0 -1.0
v 1.0 -1.0 -1.0
v 1.0 1.0 -1.0
v -1.0 -1.0 1.0
v -1.0 1.0 1.0
v 1.0 -1.0 1.0
v 1.0 1.0 1.0
vt 0 0
vt 0 1
vt 1 0
vt 1 1
f 1/1 2/2 4/4 3/3
f 5/1 6/2 2/2 1/1
f 7/3 8/4 6/2 5/1
f 3/3 4/4 8/4 7/3
f 2/2 6/2 8/4 4/4
f 5/1 1/1 3/3 7/3
"

{ $ valid-cube-obj } [ [ valid-cube-b-rep write-obj ] with-string-writer ] unit-test

{
    V{
        double-4{ -1.0 -1.0 -1.0 0.0 }
        double-4{ -1.0  1.0 -1.0 0.0 }
        double-4{  1.0 -1.0 -1.0 0.0 }
        double-4{  1.0  1.0 -1.0 0.0 }
        double-4{ -1.0 -1.0  1.0 0.0 }
        double-4{ -1.0  1.0  1.0 0.0 }
        double-4{  1.0 -1.0  1.0 0.0 }
        double-4{  1.0  1.0  1.0 0.0 }
    }
    V{
        { 0 1 3 2 }
        { 4 5 1 0 }
        { 6 7 5 4 }
        { 2 3 7 6 }
        { 1 5 7 3 }
        { 4 0 2 6 }
    }
} [
    valid-cube-obj [ (read-obj) ] with-string-reader
] unit-test

{
    V{
        double-4{ -1.0 -1.0 -1.0 0.0 }
        double-4{ -1.0  1.0 -1.0 0.0 }
        double-4{  1.0 -1.0 -1.0 0.0 }
        double-4{  1.0  1.0 -1.0 0.0 }
        double-4{ -1.0 -1.0  1.0 0.0 }
        double-4{ -1.0  1.0  1.0 0.0 }
        double-4{  1.0 -1.0  1.0 0.0 }
        double-4{  1.0  1.0  1.0 0.0 }
    }
    V{
        { 0 1 3 2 }
        { 4 5 1 0 }
        { 6 7 5 4 }
        { 2 3 7 6 }
        { 1 5 7 3 }
        { 4 0 2 6 }
    }
} [
    valid-cube-obj-relative-indices [ (read-obj) ] with-string-reader
] unit-test

{
    V{
        double-4{ -1.0 -1.0 -1.0 0.0 }
        double-4{ -1.0  1.0 -1.0 0.0 }
        double-4{  1.0 -1.0 -1.0 0.0 }
        double-4{  1.0  1.0 -1.0 0.0 }
        double-4{ -1.0 -1.0  1.0 0.0 }
        double-4{ -1.0  1.0  1.0 0.0 }
        double-4{  1.0 -1.0  1.0 0.0 }
        double-4{  1.0  1.0  1.0 0.0 }
    }
    V{
        { 0 1 3 2 }
        { 4 5 1 0 }
        { 6 7 5 4 }
        { 2 3 7 6 }
        { 1 5 7 3 }
        { 4 0 2 6 }
    }
} [
    valid-cube-obj-texcoords [ (read-obj) ] with-string-reader
] unit-test
