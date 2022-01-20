USING: accessors alien.data.map byte-arrays combinators grouping
images kernel math math.matrices.simd math.order math.vectors
math.vectors.simd noise random sequences typed ;
FROM: alien.c-types => float uchar ;
IN: terrain.generation

CONSTANT: terrain-segment-size { 512 512 }
CONSTANT: terrain-segment-size-vector float-4{ 512.0 512.0 1.0 1.0 }
CONSTANT: terrain-big-noise-scale float-4{ 0.002 0.002 0.002 0.002 }
CONSTANT: terrain-small-noise-scale float-4{ 0.05 0.05 0.05 0.05 }

TUPLE: terrain
    { big-noise-table byte-array }
    { small-noise-table byte-array }
    { tiny-noise-seed integer } ;

: <terrain> ( -- terrain )
    <perlin-noise-table> <perlin-noise-table>
    32 random-bits terrain boa ;

: seed-at ( seed at -- seed' )
    first2 [ >integer ] bi@ [ + ] dip [ 32 random-bits + ] curry with-seed ;

: big-noise-segment ( terrain at -- bytes )
    [ big-noise-table>> terrain-big-noise-scale scale-matrix4 ] dip
    terrain-segment-size-vector v* translation-matrix4 m4.
    terrain-segment-size perlin-noise-image bitmap>> ; inline
: small-noise-segment ( terrain at -- bytes )
    [ small-noise-table>> terrain-small-noise-scale scale-matrix4 ] dip
    terrain-segment-size-vector v* translation-matrix4 m4.
    terrain-segment-size perlin-noise-image bitmap>> ; inline
: tiny-noise-segment ( terrain at -- bytes )
    [ tiny-noise-seed>> ] dip seed-at
    terrain-segment-size normal-noise-image bitmap>> ; inline
: padding ( terrain at -- padding )
    2drop terrain-segment-size product 255 <repetition> >byte-array ; inline

TUPLE: segment image ;

: fold-rgba-planes ( r g b a -- rgba )
    [ vmerge-transpose vmerge-transpose ]
    data-map( uchar-16 uchar-16 uchar-16 uchar-16 -- uchar-16[4] ) ;

: <terrain-image> ( big small tiny padding -- image )
    fold-rgba-planes
    <image>
        swap >>bitmap
        RGBA >>component-order
        ubyte-components >>component-type
        terrain-segment-size >>dim ;

TYPED: terrain-segment ( terrain: terrain at: float-4 -- image )
    {
        [ big-noise-segment ]
        [ small-noise-segment ]
        [ tiny-noise-segment ]
        [ padding ]
    } 2cleave <terrain-image> ;

: 4max ( a b c d -- max )
    max max max ; inline

: mipmap ( pixels quot: ( aa ab ba bb -- c ) -- pixels' )
    [ [ 2 <groups> ] map 2 <groups> ] dip
    '[ first2 [ [ first2 ] bi@ @ ] 2map ] map ; inline

: group-pixels ( bitmap dim -- scanlines )
    [ 4 <groups> ] [ first <groups> ] bi* ;

: concat-pixels ( scanlines -- bitmap )
    [ concat ] map concat ;

: segment-mipmap ( image -- image' )
    [ clone ] [ bitmap>> ] [ dim>> ] tri
    group-pixels [ 4max ] mipmap concat-pixels >>bitmap
    [ 2 v/n ] change-dim ;
