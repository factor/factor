USING: arrays kernel math opengl opengl.gl opengl.glu ui
ui.gadgets ui.render ;
IN: nehe.2

TUPLE: nehe2-gadget ;

: width 256 ;
: height 256 ;

: <nehe2-gadget> (  -- gadget )
  nehe2-gadget construct-gadget ;

M: nehe2-gadget pref-dim* ( gadget -- dim )
  drop width height 2array ;

M: nehe2-gadget draw-gadget* ( gadget -- )
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
    0.0 1.0 0.0 glVertex3f
    -1.0 -1.0 0.0 glVertex3f
    1.0 -1.0 0.0 glVertex3f
  ] do-state
  3.0 0.0 0.0 glTranslatef
  GL_QUADS [
    -1.0 1.0 0.0 glVertex3f
    1.0 1.0 0.0 glVertex3f
    1.0 -1.0 0.0 glVertex3f
    -1.0 -1.0 0.0 glVertex3f
  ] do-state ;

: run2 ( -- )
  <nehe2-gadget> "NeHe Tutorial 2" open-window ;
