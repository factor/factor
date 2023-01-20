! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.rectangles opengl.gl
sequences ui ui.gadgets ui.render ;
IN: rosetta-code.opengl

! https://rosettacode.org/wiki/OpenGL

! In this task, the goal is to display a smooth shaded triangle
! with OpenGL.

TUPLE: triangle-gadget < gadget ;

: reshape ( width height -- )
    [ 0 0 ] 2dip glViewport
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
    GL_MODELVIEW glMatrixMode ;

: paint ( -- )
    0.3 0.3 0.3 0.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_SMOOTH glShadeModel
    glLoadIdentity
    -15.0 -15.0 0.0 glTranslatef
    GL_TRIANGLES glBegin
    1.0 0.0 0.0 glColor3f 0.0 0.0 glVertex2f
    0.0 1.0 0.0 glColor3f 30.0 0.0 glVertex2f
    0.0 0.0 1.0 glColor3f 0.0 30.0 glVertex2f
    glEnd
    glFlush ;

M: triangle-gadget pref-dim* drop { 640 480 } ;
M: triangle-gadget draw-gadget*
    rect-bounds nip first2 reshape paint ;

MAIN-WINDOW: triangle-window
    { { title "Triangle" } }
    triangle-gadget new >>gadgets ;
