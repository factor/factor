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
        5.0
    } [
        [ 255.0 v*n float-4 int-4 vconvert ] 4 napply 
        [ int-4 short-8 vconvert ] 2bi@
        short-8 uchar-16 vconvert
    ] data-map( float-4[4] -- uchar-16 )
] unit-test

: vmerge-transpose ( a b c d -- ac bd ac bd )
    [ (vmerge) ] bi-curry@ bi* ; inline

[
    B{
         1  10  11  15
         2  20  22  25
         3  30  33  35
         4  40  44  45
         5  50  55  55
         6  60  66  65
         7  70  77  75
         8  80  88  85
         9  90  99  95
        10 100 110 105
        11 110 121 115
        12 120 132 125
        13 130 143 135
        14 140 154 145
        15 150 165 155
        16 160 176 165
    }
] [
    B{   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16 }
    B{  10  20  30  40  50  60  70  80  90 100 110 120 130 140 150 160 }
    B{  11  22  33  44  55  66  77  88  99 110 121 132 143 154 165 176 }
    B{  15  25  35  45  55  65  75  85  95 105 115 125 135 145 155 165 }
    [ vmerge-transpose vmerge-transpose ]
    data-map( uchar-16 uchar-16 uchar-16 uchar-16 -- uchar-16[4] )
] unit-test
