USING: accessors arrays byte-arrays combinators fry grouping
images kernel math math.affine-transforms math.order
math.vectors noise random sequences ;
IN: terrain.generation

CONSTANT: terrain-segment-size { 512 512 }
CONSTANT: terrain-big-noise-scale { 0.002 0.002 }
CONSTANT: terrain-small-noise-scale { 0.05 0.05 }

TUPLE: terrain big-noise-table small-noise-table tiny-noise-seed ; 

: <terrain> ( -- terrain )
    <perlin-noise-table> <perlin-noise-table>
    32 random-bits terrain boa ;

: seed-at ( seed at -- seed' )
    first2 [ + ] dip [ 32 random-bits + ] curry with-seed ;

: big-noise-segment ( terrain at -- map )
    [ big-noise-table>> terrain-big-noise-scale first2 <scale> ] dip
    terrain-segment-size [ v* <translation> a. ] keep perlin-noise-byte-map ;
: small-noise-segment ( terrain at -- map )
    [ small-noise-table>> terrain-small-noise-scale first2 <scale> ] dip
    terrain-segment-size [ v* <translation> a. ] keep perlin-noise-byte-map ;
: tiny-noise-segment ( terrain at -- map )
    [ tiny-noise-seed>> ] dip seed-at 0.1
    terrain-segment-size normal-noise-byte-map ;

: padding ( terrain at -- padding )
    2drop terrain-segment-size product 255 <repetition> ;

TUPLE: segment image ;

: terrain-segment ( terrain at -- image )
    {
        [ big-noise-segment ]
        [ small-noise-segment ]
        [ tiny-noise-segment ]
        [ padding ]
    } 2cleave
    4array flip concat >byte-array
    [ terrain-segment-size RGBA f ] dip image boa ;

: 4max ( a b c d -- max )
    max max max ; inline

: mipmap ( {{pixels}} quot: ( aa ab ba bb -- c ) -- pixels' )
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
