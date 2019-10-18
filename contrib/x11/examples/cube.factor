USING: kernel sequences namespaces math threads io opengl concurrency
x xlib x11 gl concurrent-widgets ;

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

: init ( -- ) 0.0 0.0 0.0 0.0 glClearColor GL_FLAT glShadeModel ;

: display ( -- )
GL_COLOR_BUFFER_BIT glClear
1.0 1.0 1.0 glColor3f
glLoadIdentity
0.0 0.0 5.0 0.0 0.0 0.0 0.0 1.0 0.0 gluLookAt
1.0 2.0 1.0 glScalef
1.0 wire-cube
glFlush ;

: reshape ( { width height } -- )
>r 0 0 r> [ ] each glViewport
GL_PROJECTION glMatrixMode
glLoadIdentity
-1.0 1.0 -1.0 1.0 1.5 20.0 glFrustum
GL_MODELVIEW glMatrixMode
display ;

f initialize-x

create-pwindow
[ drop reshape ] over set-pwindow-resize-action
window-id win set
StructureNotifyMask select-input
{ 500 500 } resize-window { 100 100 } move-window map-window

[ GLX_RGBA ] choose-visual create-context make-current

init [ concurrent-event-loop ] spawn display