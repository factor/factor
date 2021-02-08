USING: classes classes.tuple kernel sequences vocabs math multi-generic ;
IN: multi-generic.benchmark.dispatch5

MIXIN: mg

TUPLE: x1 ;
INSTANCE: x1 mg
TUPLE: x2 ;
INSTANCE: x2 mg
TUPLE: x3 ;
INSTANCE: x3 mg
TUPLE: x4 ;
INSTANCE: x4 mg
TUPLE: x5 ;
INSTANCE: x5 mg
TUPLE: x6 ;
INSTANCE: x6 mg
TUPLE: x7 ;
INSTANCE: x7 mg
TUPLE: x8 ;
INSTANCE: x8 mg
TUPLE: x9 ;
INSTANCE: x9 mg
TUPLE: x10 ;
INSTANCE: x10 mg
TUPLE: x11 ;
INSTANCE: x11 mg
TUPLE: x12 ;
INSTANCE: x12 mg
TUPLE: x13 ;
INSTANCE: x13 mg
TUPLE: x14 ;
INSTANCE: x14 mg
TUPLE: x15 ;
INSTANCE: x15 mg
TUPLE: x16 ;
INSTANCE: x16 mg
TUPLE: x17 ;
INSTANCE: x17 mg
TUPLE: x18 ;
INSTANCE: x18 mg
TUPLE: x19 ;
INSTANCE: x19 mg
TUPLE: x20 ;
INSTANCE: x20 mg
TUPLE: x21 ;
INSTANCE: x21 mg
TUPLE: x22 ;
INSTANCE: x22 mg
TUPLE: x23 ;
INSTANCE: x23 mg
TUPLE: x24 ;
INSTANCE: x24 mg
TUPLE: x25 ;
INSTANCE: x25 mg
TUPLE: x26 ;
INSTANCE: x26 mg
TUPLE: x27 ;
INSTANCE: x27 mg
TUPLE: x28 ;
INSTANCE: x28 mg
TUPLE: x29 ;
INSTANCE: x29 mg
TUPLE: x30 ;
INSTANCE: x30 mg

: my-classes ( -- seq )
    "benchmark.dispatch5" vocab-words [ tuple-class? ] filter ;

: a-bunch-of-objects ( -- seq )
    my-classes [ new ] map ;

: dispatch5-benchmark ( -- )
    1000000 a-bunch-of-objects
    [ f [ mg? or ] reduce drop ] curry times ;

MAIN: dispatch5-benchmark
