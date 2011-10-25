USING: io.binary tools.test classes math ;
IN: io.binary.tests

[ HEX: 03020100 ] [ B{ 0 1 2 3 } le> ] unit-test
[ HEX: 00010203 ] [ B{ 0 1 2 3 } be> ] unit-test

[ HEX: 332211 ] [
    B{ HEX: 11 HEX: 22 HEX: 33 } le>
] unit-test

[ HEX: 7a2c793b2ff08554 ] [
    B{ HEX: 54 HEX: 85 HEX: f0 HEX: 2f HEX: 3b HEX: 79 HEX: 2c HEX: 7a } le>
] unit-test

[ HEX: 988a259c3433f237 ] [
    B{ HEX: 37 HEX: f2 HEX: 33 HEX: 34 HEX: 9c HEX: 25 HEX: 8a HEX: 98 } le>
] unit-test

[ B{ 0 0 4 HEX: d2 } ] [ 1234 4 >be ] unit-test
[ B{ 0 0 0 0 0 0 4 HEX: d2 } ] [ 1234 8 >be ] unit-test
[ B{ HEX: d2 4 0 0 } ] [ 1234 4 >le ] unit-test
[ B{ HEX: d2 4 0 0 0 0 0 0 } ] [ 1234 8 >le ] unit-test

[ 1234 ] [ 1234 4 >be be> ] unit-test
[ 1234 ] [ 1234 4 >le le> ] unit-test

[ fixnum ] [ B{ 0 0 0 0 0 0 0 0 0 0 } be> class-of ] unit-test

[ HEX: 56780000 HEX: 12340000 ] [ HEX: 1234000056780000 d>w/w ] unit-test
[ HEX: 5678 HEX: 1234 ] [ HEX: 12345678 w>h/h ] unit-test
[ HEX: 34 HEX: 12 ] [ HEX: 1234 h>b/b ] unit-test
