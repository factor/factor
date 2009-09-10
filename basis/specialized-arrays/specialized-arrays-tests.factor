IN: specialized-arrays.tests
USING: tools.test alien.syntax specialized-arrays
specialized-arrays sequences alien.c-types accessors
kernel arrays combinators compiler classes.struct
combinators.smart compiler.tree.debugger math libc destructors
sequences.private ;

SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: bool
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: char
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: float

[ t ] [ { 1 2 3 } >int-array int-array? ] unit-test

[ t ] [ int-array{ 1 2 3 } int-array? ] unit-test

[ 2 ] [ int-array{ 1 2 3 } second ] unit-test

[ t ] [
    { t f t } >bool-array underlying>>
    { 1 0 1 } "bool" heap-size {
        { 1 [ >char-array ] }
        { 4 [ >uint-array ] }
    } case underlying>> =
] unit-test

[ ushort-array{ 1234 } ] [
    little-endian? B{ 210 4 } B{ 4 210 } ? byte-array>ushort-array
] unit-test

[ B{ 210 4 1 } byte-array>ushort-array ] must-fail

[ { 3 1 3 3 7 } ] [
    int-array{ 3 1 3 3 7 } malloc-byte-array 5 <direct-int-array> >array
] unit-test

[ f ] [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] unit-test

[ f ] [ [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] compile-call ] unit-test

[ ushort-array{ 0 0 0 } ] [
    3 ALIEN: 123 100 <direct-ushort-array> new-sequence
    dup [ drop 0 ] change-each
] unit-test

STRUCT: test-struct
    { x int }
    { y int } ;

SPECIALIZED-ARRAY: test-struct

[ 1 ] [
    1 test-struct-array{ } new-sequence length
] unit-test

[ V{ test-struct } ] [
    [ [ test-struct-array <struct> ] test-struct-array{ } output>sequence first ] final-classes
] unit-test

: make-point ( x y -- struct )
    test-struct <struct-boa> ;

[ 5/4 ] [
    2 <test-struct-array>
    1 2 make-point over set-first
    3 4 make-point over set-second
    0 [ [ x>> ] [ y>> ] bi / + ] reduce
] unit-test

[ 5/4 ] [
    [
        2 malloc-test-struct-array
        dup &free drop
        1 2 make-point over set-first
        3 4 make-point over set-second
        0 [ [ x>> ] [ y>> ] bi / + ] reduce
    ] with-destructors
] unit-test

[ ] [ ALIEN: 123 10 <direct-test-struct-array> drop ] unit-test

[ ] [
    [
        10 malloc-test-struct-array
        &free drop
    ] with-destructors
] unit-test

[ 15 ] [ 15 10 <test-struct-array> resize length ] unit-test

[ S{ test-struct f 12 20 } ] [
    test-struct-array{
        S{ test-struct f  4 20 } 
        S{ test-struct f 12 20 }
        S{ test-struct f 20 20 }
    } second
] unit-test

! Regression
STRUCT: fixed-string { text char[100] } ;

SPECIALIZED-ARRAY: fixed-string

[ { ALIEN: 123 ALIEN: 223 ALIEN: 323 ALIEN: 423 } ] [
    ALIEN: 123 4 <direct-fixed-string-array> [ (underlying)>> ] { } map-as
] unit-test
