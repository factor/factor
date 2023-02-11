! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams kernel tools.test ;

{ 0b1111111111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    10 swap peek
] unit-test

{ 0b111111111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    9 swap peek
] unit-test

{ 0b11111111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    8 swap peek
] unit-test

{ 0b1111111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    7 swap peek
] unit-test

{ 0b111111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    6 swap peek
] unit-test

{ 0b11111 }
[
    B{ 0x0f 0xff 0xff 0xff } <msb0-bit-reader>
    2 >>byte-pos 6 >>bit-pos
    5 swap peek
] unit-test

[ B{ } <msb0-bit-reader> 5 swap peek ] must-fail
[ B{ } <msb0-bit-reader> 1 swap peek ] must-fail
[ B{ } <msb0-bit-reader> 8 swap peek ] must-fail

{ 0 } [ B{ } <msb0-bit-reader> 0 swap peek ] unit-test
