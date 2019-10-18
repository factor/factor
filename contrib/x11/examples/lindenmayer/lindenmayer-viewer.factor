USING: kernel alien math arrays sequences opengl namespaces concurrency
xlib x x11 gl concurrent-widgets lindenmayer ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: sequences

: >float-array ( seq -- )
dup length <float-array> swap dup length >array [ pick set-float-nth ] 2each ;

USE: lindenmayer

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: camera-position { 5 5 5 } camera-position set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display ( -- )
GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
camera-position get glLoadIdentity [ ] each 0.0 0.0 0.0 0.0 1.0 0.0 gluLookAt
reset result get interpret glFlush ;

: reshape ( { width height } -- )
>r 0 0 r> [ ] each glViewport
GL_PROJECTION glMatrixMode
glLoadIdentity -1.0 1.0 -1.0 1.0 1.5 200.0 glFrustum
GL_MODELVIEW glMatrixMode
display ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

f initialize-x

create-pwindow
[ drop reshape ] over set-pwindow-resize-action
[ 2drop display ] over set-pwindow-expose-action
window-id win set
ExposureMask StructureNotifyMask bitor select-input
{ 500 500 } resize-window { 0 0 } move-window map-window

[ GLX_RGBA ] choose-visual create-context make-current

0.0 0.0 0.0 0.0 glClearColor
GL_SMOOTH glShadeModel

GL_FRONT_AND_BACK GL_SPECULAR { 1.0 1.0 1.0 1.0 } >float-array glMaterialfv
GL_FRONT_AND_BACK GL_SHININESS { 50.0 } >float-array glMaterialfv
GL_LIGHT0 GL_POSITION { 1.0 1.0 1.0 0.0 } >float-array glLightfv

GL_LIGHTING glEnable
GL_LIGHT0 glEnable
GL_DEPTH_TEST glEnable

[ concurrent-event-loop ] spawn