USING: accessors math math.bitwise tools.test kernel words
specialized-arrays alien.c-types alien.data math.vectors.simd
sequences destructors libc literals classes.struct ;
SPECIALIZED-ARRAY: int
IN: math.bitwise.tests

{ 0 } [ 1 0 0 bitroll ] unit-test
{ 1 } [ 1 0 1 bitroll ] unit-test
{ 1 } [ 1 1 1 bitroll ] unit-test
{ 1 } [ 1 0 2 bitroll ] unit-test
{ 1 } [ 1 0 1 bitroll ] unit-test
{ 1 } [ 1 20 2 bitroll ] unit-test
{ 1 } [ 1 8 8 bitroll ] unit-test
{ 1 } [ 1 -8 8 bitroll ] unit-test
{ 1 } [ 1 -32 8 bitroll ] unit-test
{ 128 } [ 1 -1 8 bitroll ] unit-test
{ 8 } [ 1 3 32 bitroll ] unit-test

{ 0 } [ { } bitfield ] unit-test
{ 256 } [ 1 { 8 } bitfield ] unit-test
{ 268 } [ 3 1 { 8 2 } bitfield ] unit-test
{ 268 } [ 1 { 8 { 3 2 } } bitfield ] unit-test
: test-1+ ( x -- y ) 1 + ;
{ 512 } [ 1 { { test-1+ 8 } } bitfield ] unit-test

{ 8 } [ 0 3 toggle-bit ] unit-test
{ 0 } [ 8 3 toggle-bit ] unit-test

{ 4 } [ 0b1010101 bit-count ] unit-test
{ 0 } [ 0b0 bit-count ] unit-test
{ 1 } [ 0b1 bit-count ] unit-test
{ 2 } [ B{ 1 1 } bit-count ] unit-test
{ 64 } [ 0xffffffffffffffff bit-count ] unit-test

STRUCT: bit-count-struct { a uint } ;

{ 2 } [ S{ bit-count-struct { a 3 } } bit-count ] unit-test


SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: uint-4

{ 1 } [ uint-4{ 1 0 0 0 } bit-count ] unit-test

{ 1 } [
    [
        2 int malloc-array &free 1 0 pick set-nth bit-count
    ] with-destructors
] unit-test

{ 1 } [ B{ 1 0 0 } bit-count ] unit-test
{ 3 } [ B{ 1 1 1 } bit-count ] unit-test

{ t } [ 0b0 even-parity? ] unit-test
{ f } [ 0b1 even-parity? ] unit-test
{ f } [ 0b0 odd-parity? ] unit-test
{ t } [ 0b1 odd-parity? ] unit-test

{ -1 } [ 0xff 4 >signed ] unit-test
{ -1 } [ 0xff 8 >signed ] unit-test
{ 255 } [ 0xff 16 >signed ] unit-test

{ 2 } [ 3 >even ] unit-test
{ 3 } [ 3 >odd ] unit-test
{ 5 } [ 4 >odd ] unit-test

{ t } [ 0b111 0b110 mask? ] unit-test
{ f } [ 0b101 0b110 mask? ] unit-test
{ t } [ 0xff 1 mask? ] unit-test
{ f } [ 0x0 1 mask? ] unit-test

{ 7 } [ 5 next-odd ] unit-test
{ 7 } [ 6 next-odd ] unit-test

{ 6 } [ 5 next-even ] unit-test
{ 8 } [ 6 next-even ] unit-test

[ -1 bit-count ] [ non-negative-number-expected? ] must-fail-with
[ -1 bit-length ] [ non-negative-number-expected? ] must-fail-with

{ 0b1111 } [ 4 on-bits ] unit-test
{ 0 } [ 0 on-bits ] unit-test
{ 0 } [ -2 on-bits ] unit-test

{ 0b11 } [ 0b1111 2 bits ] unit-test
{ 0b111 } [ 0b1111 3 bits ] unit-test
{ 0 } [ 0b1111 0 bits ] unit-test
{ 0 } [ 0b1111 -2 bits ] unit-test

{ 0b111 } [ 0b111 -1 clear-bit ] unit-test
{ 0b110 } [ 0b111 0 clear-bit ] unit-test
{ 0b101 } [ 0b111 1 clear-bit ] unit-test

{ 0 } [ 0 -1 set-bit ] unit-test
{ 0b1 } [ 0 0 set-bit ] unit-test
{ 0b10 } [ 0 1 set-bit ] unit-test

{ 0 } [ 0 -1 toggle-bit ] unit-test
{ 0b1 } [ 0 0 toggle-bit ] unit-test
{ 0b10 } [ 0 1 toggle-bit ] unit-test
{ 0 } [ 0 0 toggle-bit 0 toggle-bit ] unit-test
{ 0 } [ 0 1 toggle-bit 1 toggle-bit ] unit-test

{ 0 } [ 0b1111 33 33 bit-range ] unit-test
{ 0 } [ 0b1111 33 20 bit-range ] unit-test
{ 0b11 } [ 0b1111 3 2 bit-range ] unit-test
[ 0b1111 2 3 bit-range ] [ T{ bit-range-error f 0b1111 2 3 } = ] must-fail-with
[ 0b1111 -2 -4 bit-range ] [ T{ bit-range-error f 0b1111 -2 -4 } = ] must-fail-with

{ 0 } [ 0b0 bit-length ] unit-test
{ 1 } [ 0b1 bit-length ] unit-test
{ 1 } [ 0b01 bit-length ] unit-test
{ 2 } [ 0b10 bit-length ] unit-test
{ 2 } [ 0b11 bit-length ] unit-test
{ 3 } [ 0b100 bit-length ] unit-test
{ 3 } [ 0b101 bit-length ] unit-test
{ 3 } [ 0b110 bit-length ] unit-test
{ 3 } [ 0b111 bit-length ] unit-test

{ 0x56780000 0x12340000 } [ 0x1234000056780000 d>w/w ] unit-test
{ 0x5678 0x1234 } [ 0x12345678 w>h/h ] unit-test
{ 0x34 0x12 } [ 0x1234 h>b/b ] unit-test
