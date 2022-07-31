USING: classes classes.tuple kernel multi-generic sequences vocabs math ;
IN: multi-generic.benchmark.dispatch1

MGENERIC: g ( obj -- obj )

TUPLE: x1 ;
MM: g ( :x1 -- obj ) ;
TUPLE: x2 ;
MM: g ( :x2 -- obj ) ;
TUPLE: x3 ;
MM: g ( :x3 -- obj ) ;
TUPLE: x4 ;
MM: g ( :x4 -- obj ) ;
TUPLE: x5 ;
MM: g ( :x5 -- obj ) ;
TUPLE: x6 ;
MM: g ( :x6 -- obj ) ;
TUPLE: x7 ;
MM: g ( :x7 -- obj ) ;
TUPLE: x8 ;
MM: g ( :x8 -- obj ) ;
TUPLE: x9 ;
MM: g ( :x9 -- obj ) ;
TUPLE: x10 ;
MM: g ( :x10 -- obj ) ;
TUPLE: x11 ;
MM: g ( :x11 -- obj ) ;
TUPLE: x12 ;
MM: g ( :x12 -- obj ) ;
TUPLE: x13 ;
MM: g ( :x13 -- obj ) ;
TUPLE: x14 ;
MM: g ( :x14 -- obj ) ;
TUPLE: x15 ;
MM: g ( :x15 -- obj ) ;
TUPLE: x16 ;
MM: g ( :x16 -- obj ) ;
TUPLE: x17 ;
MM: g ( :x17 -- obj ) ;
TUPLE: x18 ;
MM: g ( :x18 -- obj ) ;
TUPLE: x19 ;
MM: g ( :x19 -- obj ) ;
TUPLE: x20 ;
MM: g ( :x20 -- obj ) ;
TUPLE: x21 ;
MM: g ( :x21 -- obj ) ;
TUPLE: x22 ;
MM: g ( :x22 -- obj ) ;
TUPLE: x23 ;
MM: g ( :x23 -- obj ) ;
TUPLE: x24 ;
MM: g ( :x24 -- obj ) ;
TUPLE: x25 ;
MM: g ( :x25 -- obj ) ;
TUPLE: x26 ;
MM: g ( :x26 -- obj ) ;
TUPLE: x27 ;
MM: g ( :x27 -- obj ) ;
TUPLE: x28 ;
MM: g ( :x28 -- obj ) ;
TUPLE: x29 ;
MM: g ( :x29 -- obj ) ;
TUPLE: x30 ;
MM: g ( :x30 -- obj ) ;

: my-classes ( -- seq )
    "multi-generic.benchmark.dispatch1" vocab-words [ tuple-class? ] filter ;

: a-bunch-of-objects ( -- seq )
    my-classes [ new ] map ;

USE: prettyprint
: dispatch1-benchmark ( -- )
    1000000 a-bunch-of-objects
    [ [ g drop ] each ] curry times ;

MAIN: dispatch1-benchmark
