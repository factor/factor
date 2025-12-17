USING: accessors arrays colors columns combinators.smart kernel
locals make math math.constants math.functions math.order
math.vectors namespaces opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.pens
ui.pens.caching ui.pens.polygon ui.pens.solid ui.render ;
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

:: flat-xy-to-gl3-vertices ( flat-array color -- gl3-array )
    ! Convert flat x,y array to GL3 format: x y r g b a
    color >rgba-components :> ( r g b a )
    flat-array length 2/ :> vertex-count
    vertex-count 6 * <float-array> :> arr
    vertex-count <iota> [| i |
        i 2 * flat-array nth                i 6 * 0 + arr set-nth  ! x
        i 2 * 1 + flat-array nth            i 6 * 1 + arr set-nth  ! y
        r                                   i 6 * 2 + arr set-nth  ! r
        g                                   i 6 * 3 + arr set-nth  ! g
        b                                   i 6 * 4 + arr set-nth  ! b
        a                                   i 6 * 5 + arr set-nth  ! a
    ] each
    arr ;

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
    [ (rounded) ] [ boundary-vertices>> ] bi
    gl3-mode? get-global [
        [ upload-vertices ] [ length 6 /i ] bi GL_LINE_STRIP 0 rot glDrawArrays
    ] [
        [ gl-vertex-pointer ] [ length 2/ ] bi GL_LINE_STRIP 0 rot glDrawArrays
    ] if ;

M: rounded draw-interior
    [ (rounded) ] [ interior-vertices>> ] bi
    gl3-mode? get-global [
        [ upload-vertices ] [ length 6 /i ] bi GL_TRIANGLE_FAN 0 rot glDrawArrays
    ] [
        [ gl-vertex-pointer ] [ length 2/ ] bi GL_POLYGON 0 rot glDrawArrays
    ] if ;

M: rounded recompute-pen
    swap over [ dim>> ] [ radius>> ] bi*
    [ [ { 0 0 } ] 2dip (rounded-rect-vertices) close-path >>interior-vertices ]
    [ [ { 0 0 } swap boundary-shift ] dip (rounded-rect-vertices) >>boundary-vertices ]
    2bi gl3-mode? get-global [
        dup color>> '[ _ flat-xy-to-gl3-vertices ]
        [ change-interior-vertices ] [ change-boundary-vertices ] bi
    ] when drop ;
