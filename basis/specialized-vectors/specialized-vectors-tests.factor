IN: specialized-vectors.tests
USING: specialized-arrays specialized-vectors
tools.test kernel sequences alien.c-types vectors.functor ;
SPECIALIZED-ARRAYS: float double ;
SPECIALIZED-VECTORS: float double ;
VECTORIZED: double double-array <double-array>
VECTORIZED: float float-array <float-array>

{ 3 } [ double-vector{ 1 2 } 3 suffix! length ] unit-test

{ t } [ 10 float-array{ } new-resizable float-vector? ] unit-test
