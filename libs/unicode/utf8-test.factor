USING: utf8 test ;

[ T{ new f } { CHAR: ? } ] [ <new> { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 11111111 } utf8 ] unit-test
[ T{ new f } { BIN: 101111111000000111111 } ] [ <new> { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } utf8 ] unit-test
[ T{ new f } { CHAR: x } ] [ <new> "x" utf8 ] unit-test
[ T{ new f } { BIN: 11111000000 } ] [ <new> { BIN: 11011111 BIN: 10000000 } utf8 ] unit-test
[ T{ new f } { CHAR: ? } ] [ <new> { BIN: 10000000 } utf8 ] unit-test
[ T{ new f } { BIN: 1111000000111111 } ] [ <new> { BIN: 11101111 BIN: 10000000 BIN: 10111111 } utf8 ] unit-test

[ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } string>utf8 ] unit-test
