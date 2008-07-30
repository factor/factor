IN: float-arrays.tests
USING: float-arrays tools.test sequences.private ;

[ F{ 0.0 0.0 0.0 } ] [ 3 <float-array> ] unit-test

[ F{ 1 2 3 0 0 0 } ] [ 6 F{ 1 2 3 } resize ] unit-test

[ F{ 1 2 } ] [ 2 F{ 1 2 3 4 5 6 7 8 9 } resize ] unit-test

[ -10 F{ } resize ] must-fail

[ F{ 1.3 } ] [ 1.3 1float-array ] unit-test
