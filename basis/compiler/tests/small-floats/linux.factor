USING: alien alien.c-types alien.libraries alien.syntax kernel
math.floats.small.c-types tools.test tools.test.ffi ;
IN: compiler.tests.alien-small-floats
LIBRARY: small-floats-test

FUNCTION: double half_varargs_spill ( double named, ... half a, int a1, half b, int b1, half c, int c1, half d, int d1, half e, int e1, half f, int f1, half g, int g1, half h, int h1, half i, int i1, half j, int j1 )
FUNCTION: double bfloat_varargs_spill ( double named, ... bfloat a, int a1, bfloat b, int b1, bfloat c, int c1, bfloat d, int d1, bfloat e, int e1, bfloat f, int f1, bfloat g, int g1, bfloat h, int h1, bfloat i, int i1, bfloat j, int j1 )
{ 441.0 } [ 1.0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 half_varargs_spill small-abi-case ] unit-test
{ 441.0 } [ 1.0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 bfloat_varargs_spill small-abi-case ] unit-test
