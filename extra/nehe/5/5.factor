USING: arrays kernel math opengl opengl.gl opengl.glu ui
ui.gadgets ui.render threads ;
IN: nehe.5

TUPLE: nehe5-gadget rtri rquad thread quit? ;
: width 256 ;
: height 256 ;
: redraw-interval 10 ;

: <nehe5-gadget> (  -- gadget )
  nehe5-gadget construct-gadget
  0.0 over set-nehe5-gadget-rtri
  0.0 over set-nehe5-gadget-rquad ;

M: nehe5-gadget pref-dim* ( gadget -- dim )
  drop width height 2array ;

M: nehe5-gadget draw-gadget* ( gadget -- )
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
  dup nehe5-gadget-rtri 0.0 1.0 0.0 glRotatef

  GL_TRIANGLES [
    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    -1.0 -1.0 1.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    1.0 -1.0 1.0 glVertex3f

    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    1.0 -1.0 1.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    1.0 -1.0 -1.0 glVertex3f

    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    1.0 -1.0 -1.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    -1.0 -1.0 -1.0 glVertex3f

    1.0 0.0 0.0 glColor3f
    0.0 1.0 0.0 glVertex3f
    0.0 0.0 1.0 glColor3f
    -1.0 -1.0 -1.0 glVertex3f
    0.0 1.0 0.0 glColor3f
    -1.0 -1.0 1.0 glVertex3f
  ] do-state

  glLoadIdentity

  1.5 0.0 -7.0 glTranslatef
  dup nehe5-gadget-rquad 1.0 0.0 0.0 glRotatef
  GL_QUADS [
    0.0 1.0 0.0 glColor3f
    1.0 1.0 -1.0 glVertex3f
    -1.0 1.0 -1.0 glVertex3f
    -1.0 1.0 1.0 glVertex3f
    1.0 1.0 1.0 glVertex3f

    1.0 0.5 0.0 glColor3f
    1.0 -1.0 1.0 glVertex3f
    -1.0 -1.0 1.0 glVertex3f
    -1.0 -1.0 -1.0 glVertex3f
    1.0 -1.0 -1.0 glVertex3f

    1.0 0.0 0.0 glColor3f
    1.0 1.0 1.0 glVertex3f
    -1.0 1.0 1.0 glVertex3f
    -1.0 -1.0 1.0 glVertex3f
    1.0 -1.0 1.0 glVertex3f

    1.0 1.0 0.0 glColor3f
    1.0 -1.0 -1.0 glVertex3f
    -1.0 -1.0 -1.0 glVertex3f
    -1.0 1.0 -1.0 glVertex3f
    1.0 1.0 -1.0 glVertex3f

    0.0 0.0 1.0 glColor3f
    -1.0 1.0 1.0 glVertex3f
    -1.0 1.0 -1.0 glVertex3f
    -1.0 -1.0 -1.0 glVertex3f
    -1.0 -1.0 1.0 glVertex3f

    1.0 0.0 1.0 glColor3f
    1.0 1.0 -1.0 glVertex3f
    1.0 1.0 1.0 glVertex3f
    1.0 -1.0 1.0 glVertex3f
    1.0 -1.0 -1.0 glVertex3f
  ] do-state 
  dup nehe5-gadget-rtri 0.2 + over set-nehe5-gadget-rtri
  dup nehe5-gadget-rquad 0.15 - swap set-nehe5-gadget-rquad ;

: nehe5-update-thread ( gadget -- )  
  dup nehe5-gadget-quit? [
    redraw-interval sleep 
    dup relayout-1  
    nehe5-update-thread 
  ] unless ;

M: nehe5-gadget graft* ( gadget -- )
 [ f swap set-nehe5-gadget-quit? ] keep
 [ nehe5-update-thread ] in-thread drop ;

M: nehe5-gadget ungraft* ( gadget -- )
 t swap set-nehe5-gadget-quit? ;


: run5 ( -- )
  <nehe5-gadget> "NeHe Tutorial 5" open-window ;
