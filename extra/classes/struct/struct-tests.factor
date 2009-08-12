USING: accessors alien.c-types classes.c-types classes.struct
combinators kernel tools.test ;
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
[ 123 ] [ foo new y>> ] unit-test
[ 123 ] [ bar new foo>> y>> ] unit-test

[ 1 2 3 t ] [
    1   2 3 t foo boa   bar boa
    {
        [ w>> ] 
        [ foo>> x>> ]
        [ foo>> y>> ]
        [ foo>> z>> ]
    } cleave
] unit-test

[ 7654 ] [ S{ foo f 98 7654 f } y>> ] unit-test
[ 7654 ] [ S{ foo { y 7654 } } y>> ] unit-test
