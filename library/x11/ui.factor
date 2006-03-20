USING: kernel math namespaces opengl ;
USE: x11

":0.0" initialize-x

{ 500 500 0 } create-window
dup map-window

dup StructureNotifyMask select-input

dup choose-visual create-context make-current

: init ( -- )
    0.0 0.0 0.0 0.0 glClearColor GL_FLAT glShadeModel ;

SYMBOL: pval

:  p pval get ;
: -p pval get neg ;

: wire-cube ( size -- )
    2.0 / pval set
    GL_LINE_LOOP glBegin
    -p -p -p glVertex3f
     p -p -p glVertex3f
     p  p -p glVertex3f
    -p  p -p glVertex3f
    glEnd
    GL_LINE_LOOP glBegin
    -p -p  p glVertex3f
     p -p  p glVertex3f
     p  p  p glVertex3f
    -p  p  p glVertex3f
    glEnd
    GL_LINES glBegin
    -p -p -p glVertex3f
    -p -p  p glVertex3f
     p -p -p glVertex3f
     p -p  p glVertex3f
    -p  p -p glVertex3f
    -p  p  p glVertex3f
     p  p -p glVertex3f
     p  p  p glVertex3f
    glEnd ;

: display ( -- )
    GL_COLOR_BUFFER_BIT glClear
    1.0 1.0 1.0 glColor3f
    glLoadIdentity
    0.0 0.0 5.0 0.0 0.0 0.0 0.0 1.0 0.0 gluLookAt
    1.0 2.0 1.0 glScalef
    1.0 wire-cube
    glFlush ;

init display

dup swap-buffers

flush-dpy
