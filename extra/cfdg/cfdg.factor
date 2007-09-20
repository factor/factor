
USING: kernel alien.c-types combinators namespaces arrays
       sequences sequences.lib namespaces.lib splitting
       math math.functions math.vectors math.trig
       opengl.gl opengl.glu ui ui.gadgets.slate vars mortar slot-accessors
       random-weighted cfdg.hsv cfdg.gl ;

IN: cfdg

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: <hsba>

<hsba>
  { "hue" "saturation" "brightness" "alpha" } accessors
define-independent-class

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hsv>rgb* ( h s v -- r g b ) 3array hsv>rgb first3 ;

: gl-set-hsba ( color -- ) object-values first4 >r hsv>rgb* r> glColor4d ;

: gl-clear-hsba ( color -- ) object-values first4 >r hsv>rgb* r> glClearColor ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: color

: init-color ( -- ) 0 0 0 1 <hsba> new >color ;

: hue ( num -- ) color> tuck $hue + 360 mod >>hue drop ;

: h ( num -- ) hue ;

! if (adjustment < 0)
!   base + base * adjustment

! if (adjustment > 0)
!   base + (1 - base) * adjustment

: adjust ( val num -- val ) dup 0 > [ 1 pick - * + ] [ dupd * + ] if ;

: saturation ( num -- ) color> dup $saturation rot adjust >>saturation drop ;

: sat ( num -- ) saturation ;

: brightness ( num -- ) color> dup $brightness rot adjust >>brightness drop ;

: b ( num -- ) brightness ;

: alpha ( num -- ) color> dup $alpha rot adjust >>alpha drop ;

: a ( num -- ) alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: color-stack

: init-color-stack ( -- ) V{ } clone >color-stack ;

: clone-color ( hsba -- hsba ) object-values first4 <hsba> new ;

: push-color ( -- )
color> color-stack> push
color> clone-color >color ;

: pop-color ( -- ) color-stack> pop dup >color gl-set-hsba ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : check-size ( modelview-matrix -- num )
! { 0 1 4 5 } swap [ double-nth ] curry map
! [ abs ] map
! [ <=> ] maximum ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : check-size ( modelview-matrix -- num )
!   { 0 1 4 5 } swap [ double-nth ] curry map
!   [ abs ] map
!   biggest ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: double-nth* ( c-array indices -- seq ) swap [ double-nth ] curry map ;

: check-size ( modelview-matrix -- num )
  { 0 1 4 5 } double-nth* [ abs ] map biggest ;

VAR: threshold

: iterate? ( -- ? ) get-modelview-matrix check-size threshold get > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! cos 2a   sin 2a  0  0
! sin 2a  -cos 2a  0  0
!      0        0  1  0
!      0        0  0  1

! column major order

: gl-flip ( angle -- ) deg>rad
{ [ dup 2 * cos ] [ dup 2 * sin ] 0 0
  [ dup 2 * sin ] [ 2 * cos neg ] 0 0
  0 0 1 0
  0 0 0 1 } make* >c-double-array glMultMatrixd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: circle ( -- )
color> gl-set-hsba
gluNewQuadric dup 0 0.5 20 10 gluDisk gluDeleteQuadric ;

: triangle ( -- )
color> gl-set-hsba
GL_POLYGON glBegin
   0    0.577 glVertex2d
   0.5 -0.289 glVertex2d
  -0.5 -0.289 glVertex2d
glEnd ;

: square ( -- )
color> gl-set-hsba
GL_POLYGON glBegin
  -0.5  0.5 glVertex2d
   0.5  0.5 glVertex2d
   0.5 -0.5 glVertex2d
  -0.5 -0.5 glVertex2d
glEnd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size ( scale -- ) dup 1 glScaled ;

: s ( scale -- ) size ;

: size* ( scale-x scale-y -- ) 1 glScaled ;

: s* ( scale-x scale-y -- ) size* ;

: rotate ( angle -- ) 0 0 1 glRotated ;

: r ( angle -- ) rotate ;

: x ( x -- ) 0 0 glTranslated ;

: y ( y -- ) 0 swap 0 glTranslated ;

: flip ( angle -- ) gl-flip ;

: f ( angle -- ) flip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: do ( quot -- )
push-modelview-matrix
push-color
call
pop-modelview-matrix
pop-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: recursive ( quot -- ) iterate? swap when ;

: multi ( seq -- ) random-weighted* call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: background

: initial-background ( -- hsba ) 0 0 1 1 <hsba> new ;

: set-background ( -- )
  initial-background >color
  background> call
  color> gl-clear-hsba ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: rewrite-closures ;

VAR: viewport ! { left width bottom height }

VAR: start-shape

: initial-color ( -- hsba ) 0 0 0 1 <hsba> new ;

: display ( -- )

!   GL_LINE_SMOOTH glEnable
!   GL_BLEND glEnable
!   GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
!   GL_POINT_SMOOTH_HINT GL_NICEST glHint

!   GL_FOG glEnable
!   GL_FOG_MODE GL_LINEAR glFogi
!   GL_FOG_COLOR { 0.5 0.5 0.5 1.0 } >c-double-array glFogfv
!   GL_FOG_DENSITY 0.35 glFogf
!   GL_FOG_HINT GL_DONT_CARE glHint
!   GL_FOG_START 1.0 glFogf
!   GL_FOG_END 5.0 glFogf

  GL_PROJECTION glMatrixMode
  glLoadIdentity
  viewport> first  dup  viewport> second  +
  viewport> third  dup  viewport> fourth  + gluOrtho2D

  GL_MODELVIEW glMatrixMode
  glLoadIdentity

  set-background

  GL_COLOR_BUFFER_BIT glClear

  init-modelview-matrix-stack
  init-color-stack

  initial-color >color

  color> gl-set-hsba

  start-shape> call ;

: cfdg-window* ( -- )
[ display ] closed-quot <slate>
  { 500 500 } over set-slate-dim
  dup "CFDG" open-window ;

: cfdg-window ( -- ) [ cfdg-window* ] with-ui ;