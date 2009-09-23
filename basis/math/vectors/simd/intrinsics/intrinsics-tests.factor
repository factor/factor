IN: math.vectors.simd.intrinsics.tests
USING: math.vectors.simd.intrinsics cpu.architecture tools.test ;

[ 16 ] [ uchar-16-rep rep-components ] unit-test
[ 16 ] [ char-16-rep rep-components ] unit-test
[ 8 ] [ ushort-8-rep rep-components ] unit-test
[ 8 ] [ short-8-rep rep-components ] unit-test
[ 4 ] [ uint-4-rep rep-components ] unit-test
[ 4 ] [ int-4-rep rep-components ] unit-test
[ 4 ] [ float-4-rep rep-components ] unit-test
[ 2 ] [ double-2-rep rep-components ] unit-test

{ 4 1 } [ uint-4-rep (simd-boa) ] must-infer-as
{ 4 1 } [ int-4-rep (simd-boa) ] must-infer-as
{ 4 1 } [ float-4-rep (simd-boa) ] must-infer-as
{ 2 1 } [ double-2-rep (simd-boa) ] must-infer-as


