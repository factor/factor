USING: tools.test io.streams.byte-array io.encodings.binary
io.encodings.utf8 io kernel arrays strings ;

[ B{ 1 2 3 } ] [ binary [ { 1 2 3 } write ] with-byte-writer ] unit-test
[ B{ 1 2 3 } ] [ { 1 2 3 } binary [ 3 read ] with-byte-reader ] unit-test

[ B{ BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } utf8 [ write ] with-byte-writer ] unit-test
[ { BIN: 101111111000000111111 } t ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } utf8 <byte-reader> contents dup >array swap string? ] unit-test
