USING: accessors alien.data.map byte-arrays combinators combinators.short-circuit
fry generalizations images kernel locals math math.constants math.functions
math.libm math.matrices.simd math.vectors math.vectors.conversion math.vectors.simd
memoize random random.mersenne-twister sequences sequences.private specialized-arrays
typed ;
QUALIFIED-WITH: alien.c-types c
SIMDS: c:float c:int c:short c:uchar ;
SPECIALIZED-ARRAYS: c:float c:uchar float-4 uchar-16 ;
IN: noise

: with-seed ( seed quot -- )
    [ <mersenne-twister> ] dip with-random ; inline

: random-int-4 ( -- v )
    16 random-bytes underlying>> int-4 boa ; inline

: (random-float-4) ( -- v )
    random-int-4 int-4 float-4 vconvert ; inline

! XXX redundant add
: uniform-random-float-4 ( min max -- n )
    (random-float-4) (random-float-4)
    2.0 31 ^ v+n 2.0 32 ^ v*n v+
    [ over - 2.0 -64 ^ * ] dip n*v n+v ; inline

: normal-random-float-4 ( mean sigma -- n )
    0.0 1.0 uniform-random-float-4
    0.0 1.0 uniform-random-float-4
    [ 2 pi * v*n [ fcos ] map ]
    [ 1.0 swap n-v [ flog ] map -2.0 v*n vsqrt ]
    bi* v* n*v n+v ; inline

: float-map>byte-map ( floats: float-array scale: float bias: float -- bytes: byte-array )
    '[
        [ _ 255.0 * v*n _ 255.0 * v+n float-4 int-4 vconvert ] 4 napply 
        [ int-4 short-8 vconvert ] 2bi@
        short-8 uchar-16 vconvert
    ] data-map( float-4[4] -- uchar-16 ) ; inline

TYPED:: float-map>image ( floats: float-array dim scale: float bias: float -- image: image )
    image new
        dim >>dim
        floats scale bias float-map>byte-map >>bitmap
        L >>component-order
        ubyte-components >>component-type ;

TYPED: uniform-noise-map ( seed: integer dim -- map: float-array )
    '[
        _ product 4 / [ 0.0 1.0 uniform-random-float-4 ]
        float-4-array{ } replicate-as
        byte-array>float-array
    ] with-seed ;

: uniform-noise-image ( seed dim -- image )
    [ uniform-noise-map ] [ 1.0 0.0 float-map>image ] bi ; inline

TYPED: normal-noise-map ( seed: integer sigma: float dim -- map: float-array )
    swap '[
        _ product 4 / [ 0.5 _ normal-random-float-4 ]
        float-4-array{ } replicate-as
        byte-array>float-array
    ] with-seed ;

: normal-noise-image ( seed sigma dim -- image )
    [ normal-noise-map ] [ 1.0 0.0 float-map>image ] bi ; inline

ERROR: invalid-perlin-noise-table table ;

: <perlin-noise-table> ( -- table )
    256 iota >byte-array randomize dup append ; inline

: validate-table ( table -- table )
    dup { [ byte-array? ] [ length 512 >= ] } 1&&
    [ invalid-perlin-noise-table ] unless ;

! XXX doesn't work for NaNs or very large floats
: floor-vector ( v -- v' )
    [ float-4 int-4 vconvert int-4 float-4 vconvert ]
    [ [ v> -1.0 float-4-with vand ] curry keep v+ ] bi ; inline

: unit-cubed ( floats -- ints )
    float-4 int-4 vconvert 255 int-4-with vbitand ; inline

: fade ( gradient -- gradient' )
    {
        [ drop  6.0 ]
        [ n*v -15.0 v+n ]
        [ v*   10.0 v+n ]
        [ v* ]
        [ v* ]
        [ v* ]
    } cleave ; inline
    
:: hashes ( table x y z -- aaa baa aba bba aab bab abb bbb )
    x      table nth-unsafe y + :> a
    x  1 + table nth-unsafe y + :> b

    a      table nth-unsafe z + :> aa
    b      table nth-unsafe z + :> ba
    a  1 + table nth-unsafe z + :> ab
    b  1 + table nth-unsafe z + :> bb

    aa     table nth-unsafe
    ba     table nth-unsafe
    ab     table nth-unsafe
    bb     table nth-unsafe
    aa 1 + table nth-unsafe
    ba 1 + table nth-unsafe
    ab 1 + table nth-unsafe
    bb 1 + table nth-unsafe ; inline

:: grad ( hash v -- gradient )
    hash 8  bitand zero? [ v first ] [ v second ] if
        :> u
    hash 12 bitand zero?
    [ v second ] [ hash 13 bitand 12 = [ v first ] [ v third ] if ] if
        :> v

    hash 1 bitand zero? [ u ] [ u neg ] if
    hash 2 bitand zero? [ v ] [ v neg ] if + ; inline

TYPED:: perlin-noise ( table: byte-array point: float-4 -- value: float )
    point floor-vector :> _point_
    _point_ unit-cubed :> cube
    point _point_ v- :> gradients
    gradients fade :> faded

    table cube first3 hashes {
        [ gradients                               grad ]
        [ gradients float-4{ 1.0 0.0 0.0 0.0 } v- grad ]
        [ gradients float-4{ 0.0 1.0 0.0 0.0 } v- grad ]
        [ gradients float-4{ 1.0 1.0 0.0 0.0 } v- grad ]
        [ gradients float-4{ 0.0 0.0 1.0 0.0 } v- grad ]
        [ gradients float-4{ 1.0 0.0 1.0 0.0 } v- grad ]
        [ gradients float-4{ 0.0 1.0 1.0 0.0 } v- grad ]
        [ gradients float-4{ 1.0 1.0 1.0 0.0 } v- grad ]
    } spread
    faded trilerp ;

MEMO: perlin-noise-map-coords ( dim -- coords )
    first2 [| x y | x [ y 0.0 0.0 float-4-boa ] float-4-array{ } map-as ] with map concat ; 

TYPED:: perlin-noise-map ( table: byte-array transform: matrix4 coords: float-4-array -- map: float-array )
    coords [| coord | table transform coord m4.v perlin-noise ] data-map( float-4 -- c:float )
    byte-array>float-array ;

: perlin-noise-image ( table transform dim -- image )
    [ perlin-noise-map-coords perlin-noise-map ] [ 5/7. 0.5 float-map>image ] bi ;

