! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams io io.streams.string kernel tools.test
grouping compression.lzw multiline byte-arrays io.encodings.binary
io.streams.byte-array ;
IN: bitstreams.tests


[ BIN: 1111111111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    10 swap peek
] unit-test

[ BIN: 111111111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    9 swap peek
] unit-test

[ BIN: 11111111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    8 swap peek
] unit-test

[ BIN: 1111111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    7 swap peek
] unit-test

[ BIN: 111111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    6 swap peek
] unit-test

[ BIN: 11111 ]
[
    B{ HEX: 0f HEX: ff HEX: ff HEX: ff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    5 swap peek
] unit-test

[ B{ } <msb0-bit-reader> 5 swap peek ] must-fail
[ B{ } <msb0-bit-reader> 1 swap peek ] must-fail
[ B{ } <msb0-bit-reader> 8 swap peek ] must-fail

[ 0 ] [ B{ } <msb0-bit-reader> 0 swap peek ] unit-test
