IN: specialized-vectors.tests
USING: specialized-arrays.float
specialized-vectors.float
specialized-vectors.double
tools.test kernel sequences ;

[ 3 ] [ double-vector{ 1 2 } 3 over push length ] unit-test

[ t ] [ 10 float-array{ } new-resizable float-vector? ] unit-test