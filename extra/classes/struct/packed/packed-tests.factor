
USING: alien.c-types classes.struct.packed tools.test words ;

IN: classes.struct.packed

PACKED-STRUCT: abcd
    { a int }
    { b int }
    { c int }
    { d int }
    { e short }
    { f int }
    { g int }
    { h int }
;

[ 30 ] [ \ abcd "struct-size" word-prop ] unit-test
