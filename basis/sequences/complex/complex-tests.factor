USING: specialized-arrays sequences.complex
kernel sequences tools.test arrays accessors ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: sequences.complex.tests

: test-array ( -- x )
    float-array{ 1.0 2.0 3.0 4.0 } clone <complex-sequence> ;
: odd-length-test-array ( -- x )
    float-array{ 1.0 2.0 3.0 4.0 5.0 } clone <complex-sequence> ;

{ 2 } [ test-array length ] unit-test
{ 2 } [ odd-length-test-array length ] unit-test

{ C{ 1.0 2.0 } } [ test-array first ] unit-test
{ C{ 3.0 4.0 } } [ test-array second ] unit-test

{ { C{ 1.0 2.0 } C{ 3.0 4.0 } } }
[ test-array >array ] unit-test

{ float-array{ 1.0 2.0 5.0 6.0 } }
[ test-array [ C{ 5.0 6.0 } 1 rot set-nth ] [ seq>> ] bi ]
unit-test

{ float-array{ 7.0 0.0 3.0 4.0 } }
[ test-array [ 7.0 0 rot set-nth ] [ seq>> ] bi ]
unit-test
