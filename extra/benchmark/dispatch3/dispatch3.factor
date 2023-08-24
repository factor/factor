USING: alien.c-types sequences math mirrors grouping
kernel make assocs alien.syntax columns
specialized-arrays bit-arrays ;
SPECIALIZED-ARRAY: double
IN: benchmark.dispatch3

GENERIC: g ( obj -- str )

M: assoc g drop "assoc" ;

M: sequence g drop "sequence" ;

M: virtual-sequence g drop "virtual-sequence" ;

M: number g drop "number" ;

M: object g drop "object" ;

: objects ( -- seq )
    [
        H{ } ,
        \ + <mirror> ,
        V{ 2 3 } ,
        1 ,
        10 >bignum ,
        { 1 2 3 } ,
        "hello world" ,
        SBUF" sbuf world" ,
        V{ "a" "b" "c" } ,
        double-array{ 1.0 2.0 3.0 } ,
        "hello world" 4 tail-slice ,
        10 f <repetition> ,
        100 2 <groups> ,
        "hello" <reversed> ,
        f ,
        { { 1 2 } { 3 4 } } 0 <column> ,
        ?{ t f t } ,
        B{ 1 2 3 } ,
        [ "a" "b" "c" ] ,
        1 [ + ] curry ,
        123.456 ,
        1/6 ,
        C{ 1 2 } ,
        ALIEN: 1234 ,
    ] { } make ;

: dispatch3-benchmark ( -- )
    2000000 objects [ [ g drop ] each ] curry times ;

MAIN: dispatch3-benchmark
