USING: io.binary tools.test classes math ;
IN: io.binary.tests

[ B{ 0 0 4 HEX: d2 } ] [ 1234 4 >be ] unit-test
[ B{ 0 0 0 0 0 0 4 HEX: d2 } ] [ 1234 8 >be ] unit-test
[ B{ HEX: d2 4 0 0 } ] [ 1234 4 >le ] unit-test
[ B{ HEX: d2 4 0 0 0 0 0 0 } ] [ 1234 8 >le ] unit-test

[ 1234 ] [ 1234 4 >be be> ] unit-test
[ 1234 ] [ 1234 4 >le le> ] unit-test

[ fixnum ] [ B{ 0 0 0 0 0 0 0 0 0 0 } be> class ] unit-test

[ HEX: 56780000 HEX: 12340000 ] [ HEX: 1234000056780000 d>w/w ] unit-test
[ HEX: 5678 HEX: 1234 ] [ HEX: 12345678 w>h/h ] unit-test
[ HEX: 34 HEX: 12 ] [ HEX: 1234 h>b/b ] unit-test
