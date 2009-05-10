USING: byte-arrays combinators fry images kernel locals math
math.affine-transforms math.functions math.order
math.polynomials math.vectors random random.mersenne-twister
sequences sequences.product hints arrays sequences.private
combinators.short-circuit math.private ;
IN: noise

: <perlin-noise-table> ( -- table )
    256 iota >byte-array randomize dup append ; inline

: with-seed ( seed quot -- )
    [ <mersenne-twister> ] dip with-random ; inline

<PRIVATE

: (fade) ( x y z -- x' y' z' )
    [ { 0.0 0.0 0.0 10.0 -15.0 6.0 } polyval* ] tri@ ;

HINTS: (fade) { float float float } ;

: fade ( point -- point' )
    first3 (fade) 3array ; inline

:: grad ( hash x y z -- gradient )
    hash 8  bitand zero? [ x ] [ y ] if
        :> u
    hash 12 bitand zero?
    [ y ] [ hash 13 bitand 12 = [ x ] [ z ] if ] if
        :> v

    hash 1 bitand zero? [ u ] [ u neg ] if
    hash 2 bitand zero? [ v ] [ v neg ] if + ;

HINTS: grad { fixnum float float float } ;

: unit-cube ( point -- cube )
    [ floor >fixnum 256 rem ] map ;

:: hashes ( table x y z -- aaa baa aba bba aab bab abb bbb )
    x               table nth-unsafe y fixnum+fast :> a
    x 1 fixnum+fast table nth-unsafe y fixnum+fast :> b

    a               table nth-unsafe z fixnum+fast :> aa
    b               table nth-unsafe z fixnum+fast :> ba
    a 1 fixnum+fast table nth-unsafe z fixnum+fast :> ab
    b 1 fixnum+fast table nth-unsafe z fixnum+fast :> bb

    aa               table nth-unsafe 
    ba               table nth-unsafe 
    ab               table nth-unsafe 
    bb               table nth-unsafe 
    aa 1 fixnum+fast table nth-unsafe 
    ba 1 fixnum+fast table nth-unsafe 
    ab 1 fixnum+fast table nth-unsafe 
    bb 1 fixnum+fast table nth-unsafe ; inline

HINTS: hashes { byte-array fixnum fixnum fixnum } ;

: >byte-map ( floats -- bytes )
    [ 255.0 * >fixnum ] B{ } map-as ;

: >image ( bytes dim -- image )
    swap [ L f ] dip image boa ;

:: perlin-noise-unsafe ( table point -- value )
    point unit-cube :> cube
    point dup vfloor v- :> gradients
    gradients fade :> faded

    table cube first3 hashes {
        [ gradients first3                                    grad ]
        [ gradients first3 [ 1.0 - ] [       ] [       ] tri* grad ]
        [ gradients first3 [       ] [ 1.0 - ] [       ] tri* grad ]
        [ gradients first3 [ 1.0 - ] [ 1.0 - ] [       ] tri* grad ]
        [ gradients first3 [       ] [       ] [ 1.0 - ] tri* grad ]
        [ gradients first3 [ 1.0 - ] [       ] [ 1.0 - ] tri* grad ]
        [ gradients first3 [       ] [ 1.0 - ] [ 1.0 - ] tri* grad ]
        [ gradients first3 [ 1.0 - ] [ 1.0 - ] [ 1.0 - ] tri* grad ]
    } spread
    faded trilerp ;

ERROR: invalid-perlin-noise-table table ;

: validate-table ( table -- table )
    dup { [ byte-array? ] [ length 512 >= ] } 1&&
    [ invalid-perlin-noise-table ] unless ;

PRIVATE>

: perlin-noise ( table point -- value )
    [ validate-table ] dip perlin-noise-unsafe ; inline

: normalize-0-1 ( sequence -- sequence' )
    [ supremum ] [ infimum [ - ] keep ] [ ] tri
    [ swap - ] with map [ swap / ] with map ;

: clamp-0-1 ( sequence -- sequence' )
    [ 0.0 max 1.0 min ] map ;

: perlin-noise-map ( table transform dim -- map ) 
    [ validate-table ] 2dip
    [ iota ] map [ a.v 0.0 suffix perlin-noise-unsafe ] with with product-map ;

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
