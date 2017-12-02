IN: specialized-vectors.tests
USING: specialized-arrays specialized-vectors
tools.test kernel sequences alien.c-types vectors.functor ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTORS: float double ;
SPECIAL-VECTOR: double
SPECIAL-VECTOR: float

{ 3 } [ double-vector{ 1 2 } 3 suffix! length ] unit-test

{ t } [ 10 float-array{ } new-resizable float-vector? ] unit-test
