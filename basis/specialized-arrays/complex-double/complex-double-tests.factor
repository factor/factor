USING: kernel sequences specialized-arrays.complex-double tools.test ;
IN: specialized-arrays.complex-double.tests

[ C{ 3.0 2.0 } ]
[ complex-double-array{ 1.0 C{ 3.0 2.0 } 5.0 } second ] unit-test

[ C{ 1.0 0.0 } ]
[ complex-double-array{ 1.0 C{ 3.0 2.0 } 5.0 } first ] unit-test

[ complex-double-array{ 1.0 C{ 6.0 -7.0 } 5.0 } ] [
    complex-double-array{ 1.0 C{ 3.0 2.0 } 5.0 } 
    dup [ C{ 6.0 -7.0 } 1 ] dip set-nth
] unit-test
