USING: alien.c-types make math sequences splitting grouping
kernel columns specialized-arrays bit-arrays ;
SPECIALIZED-ARRAY: double
IN: benchmark.dispatch2

: sequences ( -- seq )
    [
        1 ,
        10 >bignum ,
        { 1 2 3 } ,
        "hello world" ,
        SBUF" sbuf world" ,
        V{ "a" "b" "c" } ,
        double-array{ 1.0 2.0 3.0 } ,
        "hello world" 4 tail-slice ,
        10 f <repetition> ,
        100 2 <sliced-groups> ,
        "hello" <reversed> ,
        { { 1 2 } { 3 4 } } 0 <column> ,
        ?{ t f t } ,
        B{ 1 2 3 } ,
        [ "a" "b" "c" ] ,
        1 [ + ] curry ,
    ] { } make ;

: don't-flush-me ( obj -- ) drop ;

: dispatch-test ( -- )
    1000000 sequences
    [ [ 0 swap nth don't-flush-me ] each ] curry times ;

MAIN: dispatch-test
