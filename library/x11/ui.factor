USING: alien kernel math namespaces opengl threads x11 ;

f initialize-x

SYMBOL: window

choose-visual

500 500 pick create-window window set

window get map-window

create-context window get swap make-current

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
    0.0 0.0 0.0 0.0 glClearColor GL_FLAT glShadeModel
    GL_COLOR_BUFFER_BIT glClear
    1.0 1.0 1.0 glColor3f
    glLoadIdentity
    0.0 0.0 5.0 0.0 0.0 0.0 0.0 1.0 0.0 gluLookAt
    1.0 2.0 1.0 glScalef
    1.0 wire-cube
    glFlush ;

display

window get swap-buffers

flush-dpy
