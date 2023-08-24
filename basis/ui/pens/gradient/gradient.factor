! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays colors combinators kernel
math math.vectors opengl opengl.gl sequences specialized-arrays
ui.pens ui.pens.caching ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: ui.pens.gradient

! Gradient pen
TUPLE: gradient < caching-pen colors last-vertices last-colors ;

: <gradient> ( colors -- gradient ) gradient new swap >>colors ;

<PRIVATE

:: gradient-vertices ( direction dim colors -- seq )
    direction dim v* dim over v- swap
    colors length [ <iota> ] [ 1 - ] bi v/n [ v*n ] with map
    swap [ over v+ 2array ] curry map
    concat concat float >c-array ;

: gradient-colors ( colors -- seq )
    [ >rgba-components 4array dup 2array ] map concat concat
    float >c-array ;

M: gradient recompute-pen
    [ nip ] [ [ [ orientation>> ] [ dim>> ] bi ] [ colors>> ] bi* ] 2bi
    [ gradient-vertices >>last-vertices ]
    [ gradient-colors >>last-colors ]
    bi drop ;

: draw-gradient ( colors -- )
    GL_COLOR_ARRAY [
        [ GL_QUAD_STRIP 0 ] dip length 2 * glDrawArrays
    ] do-enabled-client-state ;

PRIVATE>

M: gradient draw-interior
    {
        [ compute-pen ]
        [ last-vertices>> gl-vertex-pointer ]
        [ last-colors>> gl-color-pointer ]
        [ colors>> draw-gradient ]
    } cleave ;

M: gradient pen-background 2drop transparent ;
