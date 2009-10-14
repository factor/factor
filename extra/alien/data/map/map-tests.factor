! (c)Joe Groff bsd license
USING: alien.data.map generalizations kernel math.vectors
math.vectors.conversion math.vectors.simd
specialized-arrays tools.test ;
FROM: alien.c-types => uchar short int float ;
SIMDS: float int short uchar ;
SPECIALIZED-ARRAYS: int float float-4 uchar-16 ;
IN: alien.data.map.tests

[ float-array{ 1.0 1.0 3.0 3.0 5.0 5.0 } ]
[
    int-array{ 1 3 5 } [ dup ] data-map( int -- float[2] )
    byte-array>float-array
] unit-test

[ float-array{ 1.0 1.0 3.0 3.0 5.0 5.0 0.0 0.0 } ]
[
    int-array{ 1 3 5 } float-array{ 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 }
    [ dup ] data-map!( int -- float[2] )
] unit-test

[
    B{
        127 191 255 63
        255 25 51 76
        76 51 229 127
        25 255 255 255
    } 
] [
    float-array{
        0.5 0.75 1.0 0.25
        1.0 0.1 0.2 0.3
        0.3 0.2 0.9 0.5
        0.1 1.0 1.5 2.0
    } [
        [ 255.0 v*n float-4 int-4 vconvert ] 4 napply 
        [ int-4 short-8 vconvert ] 2bi@
        short-8 uchar-16 vconvert
    ] data-map( float-4[4] -- uchar-16 )
] unit-test

[
    float-array{
        0.5 0.75 1.0 0.25
        1.0 0.1 0.2 0.3
        0.3 0.2 0.9 0.5
        0.1 1.0 1.5 2.0
        5.0
    } [
        [ 255.0 v*n float-4 int-4 vconvert ] 4 napply 
        [ int-4 short-8 vconvert ] 2bi@
        short-8 uchar-16 vconvert
    ] data-map( float-4[4] -- uchar-16 )
] [ bad-data-map-input-length? ] must-fail-with
