USING: kernel math math.constants math.functions tools.test ;
IN: temporary

[ 1 C{ 0 1 } rect> ] unit-test-fails
[ C{ 0 1 } 1 rect> ] unit-test-fails

[ f ] [ C{ 5 12.5 } 5  = ] unit-test
[ t ] [ C{ 1.0 2.0 } C{ 1 2 }  = ] unit-test
[ f ] [ C{ 1.0 2.3 } C{ 1 2 }  = ] unit-test

[ C{ 2 5 } ] [ 2 5  rect> ] unit-test
[ 2 5 ] [ C{ 2 5 }  >rect ] unit-test
[ C{ 1/2 1 } ] [ 1/2 i  + ] unit-test
[ C{ 1/2 1 } ] [ i 1/2  + ] unit-test
[ t ] [ C{ 11 64 } C{ 11 64 }  = ] unit-test
[ C{ 2 1 } ] [ 2 i  + ] unit-test
[ C{ 2 1 } ] [ i 2  + ] unit-test
[ C{ 5 4 } ] [ C{ 2 2 } C{ 3 2 }  + ] unit-test
[ 5 ] [ C{ 2 2 } C{ 3 -2 }  + ] unit-test
[ C{ 1.0 1 } ] [ 1.0 i  + ] unit-test

[ C{ 1/2 -1 } ] [ 1/2 i  - ] unit-test
[ C{ -1/2 1 } ] [ i 1/2  - ] unit-test
[ C{ 1/3 1/4 } ] [ 1 3 / 1 2 / i * + 1 4 / i *  - ] unit-test
[ C{ -1/3 -1/4 } ] [ 1 4 / i * 1 3 / 1 2 / i * +  - ] unit-test
[ C{ 1/5 1/4 } ] [ C{ 3/5 1/2 } C{ 2/5 1/4 }  - ] unit-test
[ 4 ] [ C{ 5 10/3 } C{ 1 10/3 }  - ] unit-test
[ C{ 1.0 -1 } ] [ 1.0 i  - ] unit-test

[ C{ 0 1 } ] [ i 1  * ] unit-test
[ C{ 0 1 } ] [ 1 i  * ] unit-test
[ C{ 0 1.0 } ] [ 1.0 i  * ] unit-test
[ -1 ] [ i i  * ] unit-test
[ C{ 0 1 } ] [ 1 i  * ] unit-test
[ C{ 0 1 } ] [ i 1  * ] unit-test
[ C{ 0 1/2 } ] [ 1/2 i  * ] unit-test
[ C{ 0 1/2 } ] [ i 1/2  * ] unit-test
[ 2 ] [ C{ 1 1 } C{ 1 -1 }  * ] unit-test
[ 1 ] [ i -i  * ] unit-test

[ -1 ] [ i -i  / ] unit-test
[ C{ 0 1 } ] [ 1 -i  / ] unit-test
[ t ] [ C{ 12 13 } C{ 13 14 } / C{ 13 14 } * C{ 12 13 }  = ] unit-test

[ C{ -3 4 } ] [ C{ 3 -4 }  neg ] unit-test

[ 5 ] [ C{ 3 4 } abs ] unit-test
[ 5 ] [ -5.0 abs ] unit-test

! Make sure arguments are sane
[ 0 ] [ 0 arg ] unit-test
[ 0 ] [ 1 arg ] unit-test
[ t ] [ -1 arg 3.14 3.15 between? ] unit-test
[ t ] [ i arg 1.57 1.58 between? ] unit-test
[ t ] [ -i arg -1.58 -1.57 between? ] unit-test

[ 1 0 ] [ 1 >polar ] unit-test
[ 1 ] [ -1 >polar drop ] unit-test
[ t ] [ -1 >polar nip 3.14 3.15 between? ] unit-test

! I broke something
[ ] [ C{ 1 4 } tanh drop ] unit-test
[ ] [ C{ 1 4 } tan drop ] unit-test
[ ] [ C{ 1 4 } coth drop ] unit-test
[ ] [ C{ 1 4 } cot drop ] unit-test
