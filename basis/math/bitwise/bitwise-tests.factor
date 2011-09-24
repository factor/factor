USING: accessors math math.bitwise tools.test kernel words
specialized-arrays alien.c-types alien.data math.vectors.simd
sequences destructors libc literals classes.struct ;
SPECIALIZED-ARRAY: int
IN: math.bitwise.tests

[ 0 ] [ 1 0 0 bitroll ] unit-test
[ 1 ] [ 1 0 1 bitroll ] unit-test
[ 1 ] [ 1 1 1 bitroll ] unit-test
[ 1 ] [ 1 0 2 bitroll ] unit-test
[ 1 ] [ 1 0 1 bitroll ] unit-test
[ 1 ] [ 1 20 2 bitroll ] unit-test
[ 1 ] [ 1 8 8 bitroll ] unit-test
[ 1 ] [ 1 -8 8 bitroll ] unit-test
[ 1 ] [ 1 -32 8 bitroll ] unit-test
[ 128 ] [ 1 -1 8 bitroll ] unit-test
[ 8 ] [ 1 3 32 bitroll ] unit-test

[ 0 ] [ { } bitfield ] unit-test
[ 256 ] [ 1 { 8 } bitfield ] unit-test
[ 268 ] [ 3 1 { 8 2 } bitfield ] unit-test
[ 268 ] [ 1 { 8 { 3 2 } } bitfield ] unit-test
: test-1+ ( x -- y ) 1 + ;
[ 512 ] [ 1 { { test-1+ 8 } } bitfield ] unit-test

[ 8 ] [ 0 3 toggle-bit ] unit-test
[ 0 ] [ 8 3 toggle-bit ] unit-test

[ 4 ] [ BIN: 1010101 bit-count ] unit-test
[ 0 ] [ BIN: 0 bit-count ] unit-test
[ 1 ] [ BIN: 1 bit-count ] unit-test
[ 2 ] [ B{ 1 1 } bit-count ] unit-test
[ 64 ] [ HEX: ffffffffffffffff bit-count ] unit-test

STRUCT: bit-count-struct { a uint } ;

[ 2 ] [ S{ bit-count-struct { a 3 } } bit-count ] unit-test


SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: uint-4

[ 1 ] [ uint-4{ 1 0 0 0 } bit-count ] unit-test

[ 1 ] [
    [
        2 int malloc-array &free 1 0 pick set-nth bit-count
    ] with-destructors
] unit-test

[ 1 ] [ B{ 1 0 0 } bit-count ] unit-test
[ 3 ] [ B{ 1 1 1 } bit-count ] unit-test

[ t ] [ BIN: 0 even-parity? ] unit-test
[ f ] [ BIN: 1 even-parity? ] unit-test
[ f ] [ BIN: 0 odd-parity? ] unit-test
[ t ] [ BIN: 1 odd-parity? ] unit-test

[ -1 ] [ HEX: ff 4 >signed ] unit-test
[ -1 ] [ HEX: ff 8 >signed ] unit-test
[ 255 ] [ HEX: ff 16 >signed ] unit-test

[ 2 ] [ 3 >even ] unit-test
[ 3 ] [ 3 >odd ] unit-test
[ 5 ] [ 4 >odd ] unit-test

[ t ] [ HEX: ff 1 mask? ] unit-test
[ f ] [ HEX: 0 1 mask? ] unit-test

[ 7 ] [ 5 next-odd ] unit-test
[ 7 ] [ 6 next-odd ] unit-test

[ 6 ] [ 5 next-even ] unit-test
[ 8 ] [ 6 next-even ] unit-test

[ f ] [ HEX: 1 0 bit-clear? ] unit-test
[ t ] [ HEX: 0 1 bit-clear? ] unit-test

[ -1 bit-count ] [ invalid-bit-count-target? ] must-fail-with
