IN: struct-arrays.tests
USING: struct-arrays tools.test kernel math sequences
alien.syntax alien.c-types ;

C-STRUCT: test-struct
{ "int" "x" }
{ "int" "y" } ;

: make-point ( x y -- struct )
    "test-struct" <c-object>
    [ set-test-struct-y ] keep
    [ set-test-struct-x ] keep ;

[ 5/4 ] [
    2 "test-struct" <struct-array>
    1 2 make-point over set-first
    3 4 make-point over set-second
    0 [ [ test-struct-x ] [ test-struct-y ] bi / + ] reduce
] unit-test
