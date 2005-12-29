USING: kernel words namespaces sequences x x11 opengl gl ;

f initialize-x create-window win set { 250 250 } resize-window map-window

[ GLX_RGBA ] choose-visual create-context make-current

: display ( -- )
GL_COLOR_BUFFER_BIT glClear
1.0 0.0 0.0 glColor3f
GL_POLYGON glBegin
0.25 0.25 0.0 glVertex3f
0.75 0.25 0.0 glVertex3f
0.75 0.75 0.0 glVertex3f
0.25 0.75 0.0 glVertex3f
glEnd
glFlush ;

: init ( -- )
0.0 0.0 0.0 0.0 glClearColor
GL_PROJECTION glMatrixMode
glLoadIdentity
0.0 1.0 0.0 1.0 -1.0 1.0 glOrtho
;

init display