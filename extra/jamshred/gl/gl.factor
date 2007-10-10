USING: alien.c-types colors jamshred.game jamshred.oint
jamshred.player jamshred.tunnel kernel math math.vectors opengl
opengl.gl opengl.glu sequences ;
IN: jamshred.gl

: min-vertices 6 ; inline
: max-vertices 32 ; inline

: n-vertices ( -- n ) 32 ; inline

! render enough of the tunnel that it looks continuous
: n-segments-ahead ( -- n ) 60 ; inline
: n-segments-behind ( -- n ) 40 ; inline

: draw-segment-vertex ( segment theta -- )
    over segment-color gl-color segment-vertex-and-normal
    gl-normal gl-vertex ;

: draw-vertex-pair ( theta next-segment segment -- )
    rot tuck draw-segment-vertex draw-segment-vertex ;

: draw-segment ( next-segment segment -- )
    GL_QUAD_STRIP [
        [ draw-vertex-pair ] 2curry
        n-vertices equally-spaced-radians F{ 0.0 } append swap each
    ] do-state ;

: draw-segments ( segments -- )
    1 over length pick subseq swap [ draw-segment ] 2each ;

: segments-to-render ( player -- segments )
    dup player-nearest-segment segment-number dup n-segments-behind -
    swap n-segments-ahead + rot player-tunnel sub-tunnel ;

: draw-tunnel ( player -- )
    segments-to-render draw-segments ;

! : draw-tunnel ( player tunnel -- )
!     tuck swap player-nearest-segment segment-number dup n-segments-behind -
!     swap n-segments-ahead + rot sub-tunnel draw-segments ;

: init-graphics ( width height -- )
    GL_DEPTH_TEST glEnable
    GL_SCISSOR_TEST glDisable
    1.0 glClearDepth
    0.0 0.0 0.0 0.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_PROJECTION glMatrixMode glLoadIdentity
    dup 0 = [ 2drop ] [ / >float 45.0 swap 0.1 100.0 gluPerspective ] if
    GL_MODELVIEW glMatrixMode glLoadIdentity
    GL_LEQUAL glDepthFunc
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_FOG glEnable
    GL_FOG_DENSITY 0.09 glFogf
    GL_COLOR_MATERIAL glEnable
    GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE glColorMaterial
    GL_LIGHT0 GL_POSITION F{ 0.0 0.0 -3.0 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_AMBIENT F{ 0.2 0.2 0.2 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_DIFFUSE F{ 1.0 1.0 1.0 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_SPECULAR F{ 1.0 1.0 1.0 1.0 } >c-float-array glLightfv ;

: player-view ( player -- )
    [ oint-location first3 ] keep
    [ dup oint-location swap oint-forward v+ first3 ] keep
    oint-up first3 gluLookAt ;

: draw-jamshred ( jamshred width height -- )
    init-graphics jamshred-player dup player-view draw-tunnel ;

