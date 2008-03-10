USING: io.binary tools.test classes math ;
IN: io.binary.tests

[ B{ 0 0 4 HEX: d2 } ] [ 1234 4 >be ] unit-test
[ B{ HEX: d2 4 0 0 } ] [ 1234 4 >le ] unit-test

[ 1234 ] [ 1234 4 >be be> ] unit-test
[ 1234 ] [ 1234 4 >le le> ] unit-test

[ fixnum ] [ B{ 0 0 0 0 0 0 0 0 0 0 } be> class ] unit-test
