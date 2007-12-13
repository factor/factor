USING: arrays kernel math opengl opengl.gl opengl.glu ui
ui.gadgets ui.render threads ;
IN: nehe.4

TUPLE: nehe4-gadget rtri rquad thread quit? ;

: width 256 ;
: height 256 ;
: redraw-interval 10 ;

: <nehe4-gadget> (  -- gadget )
  nehe4-gadget construct-gadget
  0.0 over set-nehe4-gadget-rtri
  0.0 over set-nehe4-gadget-rquad ;

M: nehe4-gadget pref-dim* ( gadget -- dim )
  drop width height 2array ;

M: nehe4-gadget draw-gadget* ( gadget -- )
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
  dup nehe4-gadget-rtri 0.0 1.0 0.0 glRotatef

  GL_TRIANGLES [
    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    -1.0 -1.0 0.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    1.0 -1.0 0.0 glVertex3f
  ] do-state

  glLoadIdentity

  1.5 0.0 -6.0 glTranslatef
  dup nehe4-gadget-rquad 1.0 0.0 0.0 glRotatef
  0.5 0.5 1.0 glColor3f
  GL_QUADS [
    -1.0 1.0 0.0 glVertex3f
    1.0 1.0 0.0 glVertex3f
    1.0 -1.0 0.0 glVertex3f
    -1.0 -1.0 0.0 glVertex3f
  ] do-state
  dup nehe4-gadget-rtri 0.2 + over set-nehe4-gadget-rtri
  dup nehe4-gadget-rquad 0.15 - swap set-nehe4-gadget-rquad ;

: nehe4-update-thread ( gadget -- )
  dup nehe4-gadget-quit? [ drop ] [
    redraw-interval sleep
    dup relayout-1
    nehe4-update-thread
  ] if ;

M: nehe4-gadget graft* ( gadget -- )
  [ f swap set-nehe4-gadget-quit? ] keep
  [ nehe4-update-thread ] in-thread drop ;

M: nehe4-gadget ungraft* ( gadget -- )
  t swap set-nehe4-gadget-quit? ;

: run4 ( -- )
  <nehe4-gadget> "NeHe Tutorial 4" open-window ;
