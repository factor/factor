SYMBOL: loop-action
[ ] loop-action set

SYMBOL: spin
0.0 spin set

: init ( -- ) 0.0 0.0 0.0 0.0 glClearColor GL_FLAT glShadeModel ;

: display ( -- )
GL_COLOR_BUFFER_BIT glClear
glPushMatrix
spin get 0.0 0.0 1.0 glRotatef
1.0 1.0 1.0 glColor3f
-25.0 -25.0 25.0 25.0 glRectf
glPopMatrix
glXSwapBuffers ;

: spin-display ( -- )
spin get 2.0 + spin set
spin get 360.0 > [ spin get 360.0 - spin set ] when
display ;

: reshape ( { width height } -- )
>r 0 0 r> [ ] each glViewPort
GL_PROJECTION glMatrixMode glLoadIdentity
-50.0 50.0 -50.0 50.0 -1.0 1.0 glOrtho
GL_MODELVIEW glMatrixMode glLoadIdentity ;

: mouse ( event -- )
{ { [ dup XButtonEvent-button Button1Mask = ]
    [ [ spin-display ] loop-action set drop ] }
  { [ dup XButtonEvent-button Button2Mask = ]
    [ [ ] loop-action set drop ] }
  { [ t ] [ drop ] } } cond ;

: loop ( -- ) loop-action get call ;

f initialize-x

create-pwindow
[ drop reshape ] over set-pwindow-resize-action
[ drop mouse ] over set-pwindow-button-action 
window-id win set

{ 250 250 } resize-window { 100 100 } move-window map-window

[ GLX_RGBA GLX_DOUBLEBUFFER ] choose-visual create-context make-current

[ loop ] spawn