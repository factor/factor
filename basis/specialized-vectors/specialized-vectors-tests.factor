IN: specialized-vectors.tests
USING: specialized-arrays specialized-vectors
tools.test kernel sequences ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTOR: float
SPECIALIZED-VECTOR: double

[ 3 ] [ double-vector{ 1 2 } 3 over push length ] unit-test

[ t ] [ 10 float-array{ } new-resizable float-vector? ] unit-test