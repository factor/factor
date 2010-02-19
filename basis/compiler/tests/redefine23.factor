IN: compiler.tests.redefine23
USING: classes.struct specialized-arrays alien.c-types sequences
compiler.units vocabs tools.test ;

STRUCT: my-struct { x int } ;
SPECIALIZED-ARRAY: my-struct
: my-word ( a -- b ) iota [ my-struct <struct-boa> ] my-struct-array{ } map-as ;

[ ] [
    [
        "specialized-arrays.instances.compiler.tests.redefine23" forget-vocab
    ] with-compilation-unit
] unit-test
