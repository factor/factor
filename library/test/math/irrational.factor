IN: temporary
USE: kernel
USE: math
USE: math-internals
USE: test

! Lets get the argument order correct, eh?
[ 0.0 ] [ 0.0 1.0 fatan2 ] unit-test
[ 0.25 ] [ 2.0 -2.0 fpow ] unit-test

[ 4.0 ] [ 16 sqrt ] unit-test
[ C{ 0 4.0 } ] [ -16 sqrt ] unit-test

[ 4.0 ] [ 2 2 ^ ] unit-test
[ 0.25 ] [ 2 -2 ^ ] unit-test
[ t ] [ 2 0.5 ^ 2 ^ 2 2.00001 between? ] unit-test
[ t ] [ e pi i * ^ real -1.0 = ] unit-test
[ t ] [ e pi i * ^ imaginary -0.00001 0.00001 between? ] unit-test

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 1.0/0.0 ] [ 0 -2 ^ ] unit-test
[ t ] [ 0 0.0 ^ fp-nan? ] unit-test
[ 1.0/0.0 ] [ 0 -2.0 ^ ] unit-test
[ 0 ] [ 0 3.0 ^ ] unit-test
[ 0 ] [ 0 3 ^ ] unit-test

[ 1.0 ] [ 0 cosh ] unit-test
[ 0.0 ] [ 1 acosh ] unit-test
            
[ 1.0 ] [ 0 cos ] unit-test
[ 0.0 ] [ 1 acos ] unit-test
            
[ 0.0 ] [ 0 sinh ] unit-test
[ 0.0 ] [ 0 asinh ] unit-test
            
[ 0.0 ] [ 0 sin ] unit-test
[ 0.0 ] [ 0 asin ] unit-test
