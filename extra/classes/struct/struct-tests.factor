USING: classes.struct tools.test ;
IN: classes.struct.test

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
