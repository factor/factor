! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types jamshred.game jamshred.oint
jamshred.player jamshred.tunnel kernel math math.constants
math.functions math.vectors opengl opengl.gl opengl.glu
opengl.demo-support sequences specialized-arrays.float ;
IN: jamshred.gl

CONSTANT: min-vertices 6
CONSTANT: max-vertices 32

CONSTANT: n-vertices 32

! render enough of the tunnel that it looks continuous
CONSTANT: n-segments-ahead 60
CONSTANT: n-segments-behind 40

! so that we can't see through the wall, we draw it a bit further away
CONSTANT: wall-drawing-offset 0.15

: wall-drawing-radius ( segment -- r )
    radius>> wall-drawing-offset + ;

: wall-up ( segment -- v )
    [ wall-drawing-radius ] [ up>> ] bi n*v ;

: wall-left ( segment -- v )
    [ wall-drawing-radius ] [ left>> ] bi n*v ;

: segment-vertex ( theta segment -- vertex )
    [
        [ wall-up swap sin v*n ] [ wall-left swap cos v*n ] 2bi v+
    ] [
        location>> v+
    ] bi ;

: segment-vertex-normal ( vertex segment -- normal )
    location>> swap v- normalize ;

: segment-vertex-and-normal ( segment theta -- vertex normal )
    swap [ segment-vertex ] keep dupd segment-vertex-normal ;

: equally-spaced-radians ( n -- seq )
    #! return a sequence of n numbers between 0 and 2pi
    dup [ / pi 2 * * ] curry map ;

: draw-segment-vertex ( segment theta -- )
    over color>> gl-color segment-vertex-and-normal
    gl-normal gl-vertex ;

: draw-vertex-pair ( theta next-segment segment -- )
    rot tuck draw-segment-vertex draw-segment-vertex ;

: draw-segment ( next-segment segment -- )
    GL_QUAD_STRIP [
        [ draw-vertex-pair ] 2curry
        n-vertices equally-spaced-radians float-array{ 0.0 } append swap each
    ] do-state ;

: draw-segments ( segments -- )
    1 over length pick subseq swap [ draw-segment ] 2each ;

: segments-to-render ( player -- segments )
    dup nearest-segment>> number>> dup n-segments-behind -
    swap n-segments-ahead + rot tunnel>> sub-tunnel ;

: draw-tunnel ( player -- )
    segments-to-render draw-segments ;

: init-graphics ( -- )
    GL_DEPTH_TEST glEnable
    GL_SCISSOR_TEST glDisable
    1.0 glClearDepth
    0.0 0.0 0.0 0.0 glClearColor
    GL_PROJECTION glMatrixMode glPushMatrix
    GL_MODELVIEW glMatrixMode glPushMatrix
    GL_LEQUAL glDepthFunc
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_FOG glEnable
    GL_FOG_DENSITY 0.09 glFogf
    GL_FRONT GL_AMBIENT_AND_DIFFUSE glColorMaterial
    GL_COLOR_MATERIAL glEnable
    GL_LIGHT0 GL_POSITION float-array{ 0.0 0.0 0.0 1.0 } underlying>> glLightfv
    GL_LIGHT0 GL_AMBIENT float-array{ 0.2 0.2 0.2 1.0 } underlying>> glLightfv
    GL_LIGHT0 GL_DIFFUSE float-array{ 1.0 1.0 1.0 1.0 } underlying>> glLightfv
    GL_LIGHT0 GL_SPECULAR float-array{ 1.0 1.0 1.0 1.0 } underlying>> glLightfv ;

: cleanup-graphics ( -- )
    GL_DEPTH_TEST glDisable
    GL_SCISSOR_TEST glEnable
    GL_MODELVIEW glMatrixMode glPopMatrix
    GL_PROJECTION glMatrixMode glPopMatrix
    GL_LIGHTING glDisable
    GL_LIGHT0 glDisable
    GL_FOG glDisable
    GL_COLOR_MATERIAL glDisable ;

: pre-draw ( width height -- )
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_PROJECTION glMatrixMode glLoadIdentity
    dup 0 = [ 2drop ] [ / >float 45.0 swap 0.1 100.0 gluPerspective ] if
    GL_MODELVIEW glMatrixMode glLoadIdentity ;

: player-view ( player -- )
    [ location>> ]
    [ [ location>> ] [ forward>> ] bi v+ ]
    [ up>> ] tri gl-look-at ;

: draw-jamshred ( jamshred width height -- )
    pre-draw jamshred-player [ player-view ] [ draw-tunnel ] bi ;
