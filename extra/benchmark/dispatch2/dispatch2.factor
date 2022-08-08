USING: alien.c-types make math sequences grouping
kernel columns specialized-arrays bit-arrays ;
SPECIALIZED-ARRAY: double
IN: benchmark.dispatch2

: sequences ( -- seq )
    [
        1 <iota> ,
        10 >bignum <iota> ,
        { 1 2 3 } ,
        "hello world" ,
        SBUF" sbuf world" ,
        V{ "a" "b" "c" } ,
        double-array{ 1.0 2.0 3.0 } ,
        "hello world" 4 tail-slice ,
        10 f <repetition> ,
        100 <iota> 2 <groups> ,
        "hello" <reversed> ,
        { { 1 2 } { 3 4 } } 0 <column> ,
        ?{ t f t } ,
        B{ 1 2 3 } ,
        [ "a" "b" "c" ] ,
        1 [ + ] curry ,
    ] { } make ;

: don't-flush-me ( obj -- ) drop ;

: dispatch2-benchmark ( -- )
    1000000 sequences
    [ [ first don't-flush-me ] each ] curry times ;

MAIN: dispatch2-benchmark
