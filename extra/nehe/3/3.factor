USING: accessors kernel literals math opengl.demo-support
opengl.gl opengl.glu ui ui.gadgets ui.render ;
IN: nehe.3

TUPLE: nehe3-gadget < gadget ;

CONSTANT: width 256
CONSTANT: height 256

: <nehe3-gadget> ( -- gadget )
  nehe3-gadget new ;

M: nehe3-gadget draw-gadget* ( gadget -- )
  drop
  GL_PROJECTION glMatrixMode
  glLoadIdentity
  45.0 width height / >float 0.1 100.0 gluPerspective
  GL_MODELVIEW glMatrixMode
  glLoadIdentity
  GL_SMOOTH glShadeModel
  0.0 0.0 0.0 0.0 glClearColor
  1.0 glClearDepth
  GL_DEPTH_TEST glEnable
  GL_LEQUAL glDepthFunc
  GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST glHint
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
  glLoadIdentity
  -1.5 0.0 -6.0 glTranslatef
  GL_TRIANGLES [
    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    -1.0 -1.0 0.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    1.0 -1.0 0.0 glVertex3f
  ] do-state
  3.0 0.0 0.0 glTranslatef
  0.5 0.5 1.0 glColor3f
  GL_QUADS [
    -1.0 1.0 0.0 glVertex3f
    1.0 1.0 0.0 glVertex3f
    1.0 -1.0 0.0 glVertex3f
    -1.0 -1.0 0.0 glVertex3f
  ] do-state ;

MAIN-WINDOW: run3 { { title "NeHe Tutorial 3" } { pref-dim { $ width $ height } } }
  <nehe3-gadget> >>gadgets ;
