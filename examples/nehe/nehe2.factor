IN: nehe
USING: kernel gadgets opengl math arrays ;

TUPLE: nehe2-gadget ;

: width 256 ;
: height 256 ;

C: nehe2-gadget (  -- gadget )
  [ delegate>gadget ] keep ;

M: nehe2-gadget pref-dim* ( gadget -- dim )
  drop width height 0 3array ;

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
  ] with-gl
  3.0 0.0 0.0 glTranslatef
  GL_QUADS [
    -1.0 1.0 0.0 glVertex3f
    1.0 1.0 0.0 glVertex3f
    1.0 -1.0 0.0 glVertex3f
    -1.0 -1.0 0.0 glVertex3f
  ] with-gl ;

: run2 ( -- )
  <nehe2-gadget> "NeHe Tutorial 2" open-titled-window ;
