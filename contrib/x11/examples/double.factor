USING: kernel sequences namespaces math hashtables threads io opengl
concurrency x11 x gl concurrent-widgets ;

SYMBOL: loop-action

! [ ] loop-action set

SYMBOL: spin 0.0 spin set

: init ( -- ) 0.0 0.0 0.0 0.0 glClearColor GL_FLAT glShadeModel ;

: display ( -- )
GL_COLOR_BUFFER_BIT glClear
glPushMatrix
spin get 0.0 0.0 1.0 glRotatef
1.0 1.0 1.0 glColor3f
-25.0 -25.0 25.0 25.0 glRectf
glPopMatrix
swap-buffers ;

: spin-display ( -- )
spin get 2.0 + spin set
spin get 360.0 > [ spin get 360.0 - spin set ] when display ;

: reshape ( { width height } -- )
>r 0 0 r> [ ] each glViewport
GL_PROJECTION glMatrixMode glLoadIdentity
-50.0 50.0 -50.0 50.0 -1.0 1.0 glOrtho
GL_MODELVIEW glMatrixMode glLoadIdentity ;

: mouse ( event -- )
{ { [ dup XButtonEvent-button Button1 = ]
    [ global [ [ spin-display ] loop-action set ] bind drop ] }
  { [ dup XButtonEvent-button Button2 = ]
    [ global [ [ ] loop-action set ] bind drop ] }
  { [ t ] [ drop ] } } cond ;

: loop ( -- ) loop-action get call 10 sleep loop ;

! : loop ( -- ) loop-action global hash call 10 sleep loop ;

! The following line wasn't needed in 0.79
! USE: hashtables 10 <hashtable> window-table set

f initialize-x

create-pwindow
[ drop reshape ] over set-pwindow-resize-action
[ "button pressed" print drop mouse ] over set-pwindow-button-action 
window-id win set
StructureNotifyMask ButtonPressMask bitor select-input
{ 250 250 } resize-window { 100 100 } move-window map-window

[ GLX_RGBA GLX_DOUBLEBUFFER ] choose-visual create-context make-current

init [ concurrent-event-loop ] spawn [ loop ] spawn