USING: sequences.complex-components
kernel sequences tools.test arrays accessors ;
IN: sequences.complex-components.tests

: test-array ( -- x )
    { C{ 1.0 2.0 } 3.0 C{ 5.0 6.0 } } <complex-components> ;

{ 6 } [ test-array length ] unit-test

{ 1.0 } [ test-array first  ] unit-test
{ 2.0 } [ test-array second ] unit-test
{ 3.0 } [ test-array third  ] unit-test
{ 0   } [ test-array fourth ] unit-test

{ { 1.0 2.0 3.0 0 5.0 6.0 } } [ test-array >array ] unit-test
