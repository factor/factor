IN: factoroids
USING: alien kernel math namespaces opengl sdl sequences ;

: deg>rad pi * 180 / ; inline

: rad>deg 180 * pi / ; inline

: flat-projection
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    0 1 1 0 gluOrtho2D
    GL_DEPTH_TEST glDisable
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    GL_LIGHTING glDisable
    ;

: >float-array ( seq -- float-array )
    dup length dup "float" <c-array> -rot
    [ pick set-float-nth ] 2each ;

: light-source
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_LIGHT0 GL_POSITION { 1 1 1 0 } >float-array glLightfv
    GL_LIGHT0 GL_DIFFUSE { 1 0 0 1 } >float-array glLightfv
    GL_LIGHT0 GL_SPECULAR { 1 1 1 1 } >float-array glLightfv
    GL_LIGHT0 GL_AMBIENT { 0.1 0.1 0.1 1 } >float-array glLightfv ;

: world-projection
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    50 width get height get / 1 30 gluPerspective
    GL_DEPTH_TEST glEnable
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;

: factoroids-gl ( -- )
    0.0 0.0 0.0 0.0 glClearColor 
    { 1.0 0.0 0.0 0.0 } gl-color
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    0 0 width get height get glViewport
    GL_SMOOTH glShadeModel
    GL_PROJECTION glMatrixMode
    glLoadIdentity ;

: gl-normal ( normal -- ) first3 glNormal3d ;

: gl-rotate first3 glRotated ;

: gl-scale first3 glScaled ;
