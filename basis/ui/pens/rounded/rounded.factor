USING: accessors arrays columns combinators.smart kernel make
math math.constants math.functions math.order math.vectors
opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.pens
ui.pens.caching ui.pens.polygon ui.pens.solid ;
IN: ui.pens.rounded

TUPLE: rounded < solid radius ;

<PRIVATE

CONSTANT: corner-point-count 8

: alternate ( seq1 seq2 -- seq3 ) 2array flip concat ;

: clamp-radius ( radius width height -- radius' )
    min [ 2 * ] [ min ] bi* 2 / ;

: unit-rounded-corners ( points -- vertices )
    [ <iota> ] [ '[ pi * _ 2 * / [ sin ] [ cos ] bi [ 1 swap - ] bi@ 2array ] map ] bi ;

: (rounded) ( gadget pen -- ) [ compute-pen ] keep color>> gl-color ;

PRIVATE>

: <rounded> ( color radius -- solid ) rounded new swap >>radius swap >>color ;

: boundary-shift ( loc dim -- loc' dim' )
    [ 0.3 v+n ] [ 0.6 v-n ] bi* ;

:: (rounded-rect-vertices) ( loc dim radius -- vertices )
    loc dim [ first2 ] bi@ :> ( x y w h )
    radius w h clamp-radius :> r
    [
        x r + , y ,
        x w + r - , y ,
        corner-point-count unit-rounded-corners
        [ 0 <column> r neg v*n x w + v+n ]
        [ 1 <column> r v*n y v+n ] bi alternate %
        x w + , y r + ,

        x w + , y h + r - ,
        corner-point-count unit-rounded-corners
        [ 0 <column> <reversed> r neg v*n x w + v+n ]
        [ 1 <column> <reversed> r neg v*n y h + v+n ] bi alternate %
        x w + r - , y h + ,

        x r + , y h + ,
        corner-point-count unit-rounded-corners
        [ 0 <column> r v*n x v+n ]
        [ 1 <column> r neg v*n y h + v+n ] bi alternate %
        x , y h + r - ,

        x , y r + ,
        corner-point-count unit-rounded-corners
        [ 0 <column> <reversed> r v*n x v+n ]
        [ 1 <column> <reversed> r v*n y v+n ] bi alternate %
    ] float-array{ } make ;

M: rounded draw-boundary
    [ (rounded) GL_LINE_STRIP 0 ] [ boundary-vertices>> ] bi
    [ gl-vertex-pointer ] [ length 2/ glDrawArrays ] bi ;

M: rounded draw-interior
    [ (rounded) GL_POLYGON 0 ] [ interior-vertices>> ] bi
    [ gl-vertex-pointer ] [ length 2/ glDrawArrays ] bi ;

M: rounded recompute-pen
    swap over [ dim>> ] [ radius>> ] bi*
    [ [ { 0 0 } ] 2dip (rounded-rect-vertices) close-path >>interior-vertices ]
    [ [ { 0 0 } swap boundary-shift ] dip (rounded-rect-vertices) >>boundary-vertices ]
    2bi drop ;
