USING: arrays io io.encodings.string io.encodings.utf8
io.streams.byte-array kernel sequences strings tools.test ;
IN: io.encodings.utf8.tests

: decode-utf8-w/stream ( array -- newarray )
    utf8 decode >array ;

: encode-utf8-w/stream ( array -- newarray )
    >string utf8 encode >array ;

{ { CHAR: replacement-character } } [ { 0b11110,101 0b10,111111 0b10,000000 0b11111111 } decode-utf8-w/stream ] unit-test

{ "x" } [ "x" decode-utf8-w/stream >string ] unit-test

{ { 0b11111000000 } } [ { 0b110,11111 0b10,000000 } decode-utf8-w/stream >array ] unit-test

{ { CHAR: replacement-character } } [ { 0b10000000 } decode-utf8-w/stream ] unit-test

{ { 0b1111000000111111 } } [ { 0b1110,1111 0b10,000000 0b10,111111 } decode-utf8-w/stream >array ] unit-test

{ { 0b11110,101 0b10,111111 0b10,000000 0b10,111111 0b1110,1111 0b10,000000 0b10,111111 0b110,11111 0b10,000000 CHAR: x } }
[ { 0b101111111000000111111 0b1111000000111111 0b11111000000 CHAR: x } encode-utf8-w/stream ] unit-test

{ 3 } [ 1 "日本語" >utf8-index ] unit-test
{ 3 } [ 9 "日本語" utf8-index> ] unit-test

{ 3 } [ 2 "lápis" >utf8-index ] unit-test

{ V{ } } [ 100000 <iota> [ [ code-point-length ] [ 1string utf8 encode length ] bi = ] reject ] unit-test

{ { CHAR: replacement-character } } [ { 0b110,00000 0b10,000000 } decode-utf8-w/stream ] unit-test
{ { CHAR: replacement-character } } [ { 0b110,00001 0b10,111111 } decode-utf8-w/stream ] unit-test
{ { 0x80 } } [ { 0b110,00010 0b10,000000 } decode-utf8-w/stream ] unit-test

{ { CHAR: replacement-character } } [ { 0b1110,0000 0b10,000000 0b10,000000 } decode-utf8-w/stream ] unit-test
{ { CHAR: replacement-character } } [ { 0b1110,0000 0b10,011111 0b10,111111 } decode-utf8-w/stream ] unit-test
{ { 0x800 } } [ { 0b1110,0000 0b10,100000 0b10,000000 } decode-utf8-w/stream ] unit-test

{ { CHAR: replacement-character } } [ { 0b11110,000 0b10,000000 0b10,000000 0b10,000000 } decode-utf8-w/stream ] unit-test
{ { CHAR: replacement-character } } [ { 0b11110,000 0b10,001111 0b10,111111 0b10,111111 } decode-utf8-w/stream ] unit-test
{ { CHAR: replacement-character } } [ { 0b11110,100 0b10,010000 0b10,000000 0b10,000000 } decode-utf8-w/stream ] unit-test
{ { 0x10000 } } [ { 0b11110,000 0b10,010000 0b10,000000 0b10,000000 } decode-utf8-w/stream ] unit-test
{ { 0x10FFFF } } [ { 0b11110,100 0b10,001111 0b10,111111 0b10,111111 } decode-utf8-w/stream ] unit-test

! test BOM skipping

{ "abc" } [
    B{ 0xef 0xbb 0xbf 0x61 0x62 0x63 } utf8-bom [ readln ] with-byte-reader
] unit-test

{ "abc" } [
    B{ 0x61 0x62 0x63 } utf8-bom [ readln ] with-byte-reader
] unit-test
