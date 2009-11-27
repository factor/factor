USING: io.encodings.utf8 tools.test io.encodings.string strings arrays
bootstrap.unicode kernel sequences ;
IN: io.encodings.utf8.tests

: decode-utf8-w/stream ( array -- newarray )
    utf8 decode >array ;

: encode-utf8-w/stream ( array -- newarray )
    >string utf8 encode >array ;

[ { CHAR: replacement-character } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 11111111 } decode-utf8-w/stream ] unit-test

[ { BIN: 101111111000000111111 } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream ] unit-test

[ "x" ] [ "x" decode-utf8-w/stream >string ] unit-test

[ { BIN: 11111000000 } ] [ { BIN: 11011111 BIN: 10000000 } decode-utf8-w/stream >array ] unit-test

[ { CHAR: replacement-character } ] [ { BIN: 10000000 } decode-utf8-w/stream ] unit-test

[ { BIN: 1111000000111111 } ] [ { BIN: 11101111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } encode-utf8-w/stream ] unit-test

[ 3 ] [ 1 "日本語" >utf8-index ] unit-test
[ 3 ] [ 9 "日本語" utf8-index> ] unit-test

[ 3 ] [ 2 "lápis" >utf8-index ] unit-test

[ V{ } ] [ 100000 [ [ code-point-length ] [ 1string utf8 encode length ] bi = not ] filter ] unit-test
