USING: io.utf8 tools.test strings ;

[ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 11111111 } decode-utf8 ] unit-test-fails

[ { BIN: 101111111000000111111 } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } decode-utf8 ] unit-test

[ "x" ] [ "x" decode-utf8 >string ] unit-test

[ { BIN: 11111000000 } ] [ { BIN: 11011111 BIN: 10000000 } decode-utf8 ] unit-test

[ { BIN: 10000000 } decode-utf8 ] unit-test-fails

[ { BIN: 1111000000111111 } ] [ { BIN: 11101111 BIN: 10000000 BIN: 10111111 } decode-utf8 ] unit-test

[ B{ BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } encode-utf8 ] unit-test
