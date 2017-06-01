IN: compiler.tests.redefine23
USING: classes.struct specialized-arrays alien.c-types sequences
compiler.units vocabs tools.test specialized-arrays.private ;

STRUCT: my-struct { x int } ;
SPECIALIZED-ARRAY: my-struct
: my-word ( a -- b ) <iota> [ my-struct <struct-boa> ] my-struct-array{ } map-as ;

[ ] [
    [
        my-struct specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test
