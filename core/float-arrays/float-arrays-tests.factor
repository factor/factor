IN: temporary
USING: float-arrays tools.test ;

[ F{ 1.0 1.0 1.0 } ] [ 3 1.0 <float-array> ] unit-test

[ F{ 1 2 3 0 0 0 } ] [ 6 F{ 1 2 3 } resize-float-array ] unit-test

[ F{ 1 2 } ] [ 2 F{ 1 2 3 4 5 6 7 8 9 } resize-float-array ] unit-test

[ -10 F{ } resize-float-array ] unit-test-fails
