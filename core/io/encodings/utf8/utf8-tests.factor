USING: io.encodings.utf8 tools.test sbufs kernel io
sequences strings arrays unicode ;

: decode-utf8-w/stream ( array -- newarray )
    >sbuf dup reverse-here <utf8> contents >array ;

: encode-utf8-w/stream ( array -- newarray )
    SBUF" " clone tuck <utf8> write >array ;

[ { CHAR: replacement-character } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 11111111 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 101111111000000111111 } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream >array ] unit-test

[ "x" ] [ "x" decode-utf8-w/stream >string ] unit-test

[ { BIN: 11111000000 } ] [ { BIN: 11011111 BIN: 10000000 } decode-utf8-w/stream >array ] unit-test

[ { CHAR: replacement-character } ] [ { BIN: 10000000 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 1111000000111111 } ] [ { BIN: 11101111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream >array ] unit-test

[ B{ BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } encode-utf8 ] unit-test
