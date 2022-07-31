USING: alien.c-types sequences math mirrors splitting grouping
kernel make assocs alien.syntax columns multi-generic
specialized-arrays bit-arrays ;
SPECIALIZED-ARRAY: double
IN: multi-generic.benchmark.dispatch3

MGENERIC: g ( obj -- str )

MM: g ( :assoc -- str ) drop "assoc" ;

MM: g ( :sequence -- str ) drop "sequence" ;

MM: g ( :virtual-sequence -- str ) drop "virtual-sequence" ;

MM: g ( :number -- str ) drop "number" ;

MM: g ( :object -- str ) drop "object" ;

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
