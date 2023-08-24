USING: alien.c-types alien.data arrays io io.encodings.ascii
io.encodings.binary io.encodings.utf8 io.streams.byte-array
kernel math specialized-arrays strings tools.test ;
SPECIALIZED-ARRAY: int

{ B{ } } [ B{ } binary [ read-contents ] with-byte-reader ] unit-test

! Issue #70 github
{ f } [ B{ } binary [ 0 read ] with-byte-reader ] unit-test
{ f } [ B{ } binary [ 1 read ] with-byte-reader ] unit-test
{ f } [ B{ } ascii [ 0 read ] with-byte-reader ] unit-test
{ f } [ B{ } ascii [ readln ] with-byte-reader ] unit-test
{ f f } [ B{ } ascii [ "a" read-until ] with-byte-reader ] unit-test
{ f f } [ B{ } binary [ { 2 } read-until ] with-byte-reader ] unit-test


{ B{ 1 2 3 } } [ binary [ B{ 1 2 3 } write ] with-byte-writer ] unit-test
{ B{ 1 2 3 4 5 6 } } [ binary [ B{ 1 2 3 } write B{ 4 5 6 } write ] with-byte-writer ] unit-test
{ B{ 1 2 3 } } [ { 1 2 3 } binary [ 3 read ] with-byte-reader ] unit-test

{ B{ 0b11110101 0b10111111 0b10000000 0b10111111 0b11101111 0b10000000 0b10111111 0b11011111 0b10000000 CHAR: x } }
[ { 0b101111111000000111111 0b1111000000111111 0b11111000000 CHAR: x } >string utf8 [ write ] with-byte-writer ] unit-test
{ { 0b1111111000000111111 } t } [ { 0b11110001 0b10111111 0b10000000 0b10111111 } utf8 <byte-reader> stream-contents dup >array swap string? ] unit-test

{ B{ 121 120 } 0 } [
    B{ 0 121 120 0 0 0 0 0 0 } binary
    [ 1 read drop "\0" read-until ] with-byte-reader
] unit-test


{ B{ } 1 } [
    B{ 1 2 3 } binary [ B{ 1 } read-until ] with-byte-reader
] unit-test

{ f f } [
    B{ } binary [ B{ 0 } read-until ] with-byte-reader
] unit-test

{ 1 1 4 11 f } [
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 } binary
    [
        read1
        0 seek-absolute seek-input
        read1
        2 seek-relative seek-input
        read1
        -2 seek-end seek-input
        read1
        0 seek-end seek-input
        read1
    ] with-byte-reader
] unit-test

{ 0 } [
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 } binary [ tell-input ] with-byte-reader
] unit-test

! Overly aggressive compiler optimizations
{ B{ 123 } } [
    binary [ 123 >bignum write1 ] with-byte-writer
] unit-test

! Writing specialized arrays to byte writers
{ int-array{ 1 2 3 } } [
    binary [ int-array{ 1 2 3 } write ] with-byte-writer
    int cast-array
] unit-test
