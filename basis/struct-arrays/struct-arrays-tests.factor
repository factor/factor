IN: struct-arrays.tests
USING: classes.struct struct-arrays tools.test kernel math sequences
alien.syntax alien.c-types destructors libc accessors sequences.private ;

STRUCT: test-struct-array
    { x int }
    { y int } ;

: make-point ( x y -- struct )
    test-struct-array <struct-boa> ;

[ 5/4 ] [
    2 test-struct-array <struct-array>
    1 2 make-point over set-first
    3 4 make-point over set-second
    0 [ [ x>> ] [ y>> ] bi / + ] reduce
] unit-test

[ 5/4 ] [
    [
        2 test-struct-array malloc-struct-array
        dup &free drop
        1 2 make-point over set-first
        3 4 make-point over set-second
        0 [ [ x>> ] [ y>> ] bi / + ] reduce
    ] with-destructors
] unit-test

[ ] [ ALIEN: 123 10 test-struct-array <direct-struct-array> drop ] unit-test

[ ] [
    [
        10 test-struct-array malloc-struct-array
        &free drop
    ] with-destructors
] unit-test

[ 15 ] [ 15 10 test-struct-array <struct-array> resize length ] unit-test

[ S{ test-struct-array f 12 20 } ] [
    struct-array{ test-struct-array
        S{ test-struct-array f  4 20 } 
        S{ test-struct-array f 12 20 }
        S{ test-struct-array f 20 20 }
    } second
] unit-test
