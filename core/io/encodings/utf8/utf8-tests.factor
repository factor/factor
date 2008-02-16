USING: io.encodings.utf8 tools.test sbufs kernel io io.encodings
sequences strings arrays unicode.syntax ;

: decode-utf8-w/stream ( array -- newarray )
    >sbuf dup reverse-here utf8 <decoding> contents ;

: encode-utf8-w/stream ( array -- newarray )
    SBUF" " clone tuck utf8 <encoding> stream-write >array ;

[ { UNICHAR: replacement-character } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 11111111 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 101111111000000111111 } ] [ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream >array ] unit-test

[ "x" ] [ "x" decode-utf8-w/stream >string ] unit-test

[ { BIN: 11111000000 } ] [ { BIN: 11011111 BIN: 10000000 } decode-utf8-w/stream >array ] unit-test

[ { UNICHAR: replacement-character } ] [ { BIN: 10000000 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 1111000000111111 } ] [ { BIN: 11101111 BIN: 10000000 BIN: 10111111 } decode-utf8-w/stream >array ] unit-test

[ { BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } encode-utf8-w/stream ] unit-test
