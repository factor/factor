! (c)Joe Groff bsd license
USING: accessors alien.c-types classes.c-types classes.struct
combinators io.streams.string kernel libc math namespaces
prettyprint prettyprint.config tools.test ;
IN: classes.struct.tests

STRUCT: foo
    { x char }
    { y int initial: 123 }
    { z boolean } ;

STRUCT: bar
    { w ushort initial: HEX: ffff }
    { foo foo } ;

[ 12 ] [ foo heap-size ] unit-test
[ 16 ] [ bar heap-size ] unit-test
[ 123 ] [ foo <struct> y>> ] unit-test
[ 123 ] [ bar <struct> foo>> y>> ] unit-test

[ 1 2 3 t ] [
    1   2 3 t foo <struct-boa>   bar <struct-boa>
    {
        [ w>> ] 
        [ foo>> x>> ]
        [ foo>> y>> ]
        [ foo>> z>> ]
    } cleave
] unit-test

[ 7654 ] [ S{ foo f 98 7654 f } y>> ] unit-test
[ 7654 ] [ S{ foo { y 7654 } } y>> ] unit-test

UNION-STRUCT: float-and-bits
    { f single-float }
    { bits uint } ;

[ 1.0 ] [ float-and-bits <struct> 1.0 float>bits >>bits f>> ] unit-test
[ 4 ] [ float-and-bits heap-size ] unit-test

[ ] [ foo malloc-struct free ] unit-test

[ "S{ foo { y 7654 } }" ]
[ f boa-tuples? [ foo <struct> 7654 >>y [ pprint ] with-string-writer ] with-variable ] unit-test

[ "S{ foo f 0 7654 f }" ]
[ t boa-tuples? [ foo <struct> 7654 >>y [ pprint ] with-string-writer ] with-variable ] unit-test

