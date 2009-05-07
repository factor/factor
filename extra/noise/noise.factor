USING: byte-arrays combinators fry images kernel locals math
math.affine-transforms math.functions math.order
math.polynomials math.vectors random random.mersenne-twister
sequences sequences.product ;
IN: noise

: <perlin-noise-table> ( -- table )
    256 iota >byte-array randomize dup append ;

<PRIVATE

: fade ( point -- point' )
    { 0.0 0.0 0.0 10.0 -15.0 6.0 } swap [ polyval ] with map ;

:: grad ( hash gradients -- gradient )
    hash 8  bitand zero? [ gradients first ] [ gradients second ] if
        :> u
    hash 12 bitand zero?
    [ gradients second ]
    [ hash 13 bitand 12 = [ gradients first ] [ gradients third ] if ] if
        :> v

    hash 1 bitand zero? [ u ] [ u neg ] if
    hash 2 bitand zero? [ v ] [ v neg ] if + ;

: unit-cube ( point -- cube )
    [ floor >fixnum 256 mod ] map ;

:: hashes ( table cube -- aaa baa aba bba aab bab abb bbb )
    cube first  :> x
    cube second :> y
    cube third  :> z
    x     table nth y + :> a
    x 1 + table nth y + :> b

    a     table nth z + :> aa
    b     table nth z + :> ba
    a 1 + table nth z + :> ab
    b 1 + table nth z + :> bb

    aa     table nth 
    ba     table nth 
    ab     table nth 
    bb     table nth 
    aa 1 + table nth 
    ba 1 + table nth 
    ab 1 + table nth 
    bb 1 + table nth ;

:: 2tetra@ ( p q r s t u v w quot -- )
    p q quot call
    r s quot call
    t u quot call
    v w quot call
    ; inline

: with-seed ( seed quot -- )
    [ <mersenne-twister> ] dip with-random ; inline

: >byte-map ( floats -- bytes )
    [ 255.0 * >fixnum ] B{ } map-as ;

: >image ( bytes dim -- image )
    swap [ L f ] dip image boa ;

PRIVATE>

:: perlin-noise ( table point -- value )
    point unit-cube :> cube
    point dup vfloor v- :> gradients
    gradients fade :> faded

    table cube hashes {
        [ gradients                       grad ]
        [ gradients { -1.0  0.0  0.0 } v+ grad ]
        [ gradients {  0.0 -1.0  0.0 } v+ grad ]
        [ gradients { -1.0 -1.0  0.0 } v+ grad ]
        [ gradients {  0.0  0.0 -1.0 } v+ grad ]
        [ gradients { -1.0  0.0 -1.0 } v+ grad ]
        [ gradients {  0.0 -1.0 -1.0 } v+ grad ]
        [ gradients { -1.0 -1.0 -1.0 } v+ grad ]
    } spread
    [ faded first lerp ] 2tetra@
    [ faded second lerp ] 2bi@
    faded third lerp ;

: normalize-0-1 ( sequence -- sequence' )
    [ supremum ] [ infimum [ - ] keep ] [ ] tri
    [ swap - ] with map [ swap / ] with map ;

: clamp-0-1 ( sequence -- sequence' )
    [ 0.0 max 1.0 min ] map ;

: perlin-noise-map ( table transform dim -- map ) 
    [ iota ] map [ a.v 0.0 suffix perlin-noise ] with with product-map ;

: perlin-noise-byte-map ( table transform dim -- map )
    perlin-noise-map normalize-0-1 >byte-map ;

: perlin-noise-image ( table transform dim -- image )
    [ perlin-noise-byte-map ] [ >image ] bi ;

: uniform-noise-map ( seed dim -- map )
    [ product [ 0.0 1.0 uniform-random-float ] replicate ]
    curry with-seed ;

: uniform-noise-byte-map ( seed dim -- map )
    uniform-noise-map >byte-map ;

: uniform-noise-image ( seed dim -- image )
    [ uniform-noise-byte-map ] [ >image ] bi ;

: normal-noise-map ( seed sigma dim -- map )
    swap '[ _ product [ 0.5 _ normal-random-float ] replicate ]
    with-seed ;

: normal-noise-byte-map ( seed sigma dim -- map )
    normal-noise-map clamp-0-1 >byte-map ;

: normal-noise-image ( seed sigma dim -- image )
    [ normal-noise-byte-map ] [ >image ] bi ;
