USING: classes.tuple kernel sequences vocabs math ;
IN: benchmark.dispatch5

MIXIN: g

TUPLE: x1 ;
INSTANCE: x1 g
TUPLE: x2 ;
INSTANCE: x2 g
TUPLE: x3 ;
INSTANCE: x3 g
TUPLE: x4 ;
INSTANCE: x4 g
TUPLE: x5 ;
INSTANCE: x5 g
TUPLE: x6 ;
INSTANCE: x6 g
TUPLE: x7 ;
INSTANCE: x7 g
TUPLE: x8 ;
INSTANCE: x8 g
TUPLE: x9 ;
INSTANCE: x9 g
TUPLE: x10 ;
INSTANCE: x10 g
TUPLE: x11 ;
INSTANCE: x11 g
TUPLE: x12 ;
INSTANCE: x12 g
TUPLE: x13 ;
INSTANCE: x13 g
TUPLE: x14 ;
INSTANCE: x14 g
TUPLE: x15 ;
INSTANCE: x15 g
TUPLE: x16 ;
INSTANCE: x16 g
TUPLE: x17 ;
INSTANCE: x17 g
TUPLE: x18 ;
INSTANCE: x18 g
TUPLE: x19 ;
INSTANCE: x19 g
TUPLE: x20 ;
INSTANCE: x20 g
TUPLE: x21 ;
INSTANCE: x21 g
TUPLE: x22 ;
INSTANCE: x22 g
TUPLE: x23 ;
INSTANCE: x23 g
TUPLE: x24 ;
INSTANCE: x24 g
TUPLE: x25 ;
INSTANCE: x25 g
TUPLE: x26 ;
INSTANCE: x26 g
TUPLE: x27 ;
INSTANCE: x27 g
TUPLE: x28 ;
INSTANCE: x28 g
TUPLE: x29 ;
INSTANCE: x29 g
TUPLE: x30 ;
INSTANCE: x30 g

: my-classes ( -- seq )
    "benchmark.dispatch5" vocab-words [ tuple-class? ] filter ;

: a-bunch-of-objects ( -- seq )
    my-classes [ new ] map ;

: dispatch5-benchmark ( -- )
    1000000 a-bunch-of-objects
    [ f [ g? or ] reduce drop ] curry times ;

MAIN: dispatch5-benchmark
