USING: classes.tuple kernel sequences vocabs math ;
IN: benchmark.dispatch1

GENERIC: g ( obj -- obj )

TUPLE: x1 ;
M: x1 g ;
TUPLE: x2 ;
M: x2 g ;
TUPLE: x3 ;
M: x3 g ;
TUPLE: x4 ;
M: x4 g ;
TUPLE: x5 ;
M: x5 g ;
TUPLE: x6 ;
M: x6 g ;
TUPLE: x7 ;
M: x7 g ;
TUPLE: x8 ;
M: x8 g ;
TUPLE: x9 ;
M: x9 g ;
TUPLE: x10 ;
M: x10 g ;
TUPLE: x11 ;
M: x11 g ;
TUPLE: x12 ;
M: x12 g ;
TUPLE: x13 ;
M: x13 g ;
TUPLE: x14 ;
M: x14 g ;
TUPLE: x15 ;
M: x15 g ;
TUPLE: x16 ;
M: x16 g ;
TUPLE: x17 ;
M: x17 g ;
TUPLE: x18 ;
M: x18 g ;
TUPLE: x19 ;
M: x19 g ;
TUPLE: x20 ;
M: x20 g ;
TUPLE: x21 ;
M: x21 g ;
TUPLE: x22 ;
M: x22 g ;
TUPLE: x23 ;
M: x23 g ;
TUPLE: x24 ;
M: x24 g ;
TUPLE: x25 ;
M: x25 g ;
TUPLE: x26 ;
M: x26 g ;
TUPLE: x27 ;
M: x27 g ;
TUPLE: x28 ;
M: x28 g ;
TUPLE: x29 ;
M: x29 g ;
TUPLE: x30 ;
M: x30 g ;

: my-classes ( -- seq )
    "benchmark.dispatch1" vocab-words [ tuple-class? ] filter ;

: a-bunch-of-objects ( -- seq )
    my-classes [ new ] map ;

: dispatch1-benchmark ( -- )
    1000000 a-bunch-of-objects
    [ [ g drop ] each ] curry times ;

MAIN: dispatch1-benchmark
