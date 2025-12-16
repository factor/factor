! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays grouping kernel
math math.constants math.functions namespaces opengl opengl.gl
sequences specialized-arrays
specialized-arrays.instances.alien.c-types.float ui.gadgets
ui.pens ui.render ;
FROM: alien.c-types => float ;
IN: ui.pens.polygon

! Polygon pen
TUPLE: polygon color
interior-vertices
interior-count
boundary-vertices
boundary-count ;

M: polygon pen-pref-dim boundary-vertices>> 2 <groups> max-dims nip ;

: close-path ( points -- points' )
    dup first suffix ;

: <polygon> ( color points -- polygon )
    dup close-path [ [ concat float >c-array ] [ length ] bi ] bi@
    polygon boa ;

M: polygon draw-boundary
    nip
    gl3-mode? get-global [
        ! GL3 mode: use gl-color (with hook) and make-position-vertices
        [ color>> gl-color ]
        [
            boundary-vertices>> 2 <groups>
            make-position-vertices upload-vertices
        ]
        [ [ GL_LINE_STRIP 0 ] dip boundary-count>> glDrawArrays ]
        tri
    ] [
        ! Legacy mode: use gl-color and gl-vertex-pointer
        [ color>> gl-color ]
        [ boundary-vertices>> gl-vertex-pointer ]
        [ [ GL_LINE_STRIP 0 ] dip boundary-count>> glDrawArrays ]
        tri
    ] if ;

M: polygon draw-interior
    nip
    gl3-mode? get-global [
        ! GL3 mode: use GL_TRIANGLE_FAN instead of GL_POLYGON
        [ color>> gl-color ]
        [
            interior-vertices>> 2 <groups>
            make-position-vertices upload-vertices
        ]
        [ [ GL_TRIANGLE_FAN 0 ] dip interior-count>> glDrawArrays ]
        tri
    ] [
        ! Legacy mode: use GL_POLYGON
        [ color>> gl-color ]
        [ interior-vertices>> gl-vertex-pointer ]
        [ [ GL_POLYGON 0 ] dip interior-count>> glDrawArrays ]
        tri
    ] if ;

: <polygon-gadget> ( color points -- gadget )
    [ <polygon> ] [ max-dims ] bi
    [ <gadget> ] 2dip [ >>interior ] [ >>dim ] bi* ;

:: polygon-circle ( n diameter -- vertices )
    n 1 + <iota> [ 2 pi * * n / [ sin ] [ cos ] bi 2array ] map
    diameter 2 / '[ [ _ [ * ] [ + ] bi round >fixnum ] map ] map ;


