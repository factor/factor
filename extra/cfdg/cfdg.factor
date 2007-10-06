
USING: kernel alien.c-types combinators namespaces arrays
       sequences sequences.lib namespaces.lib splitting
       math math.functions math.vectors math.trig
       opengl.gl opengl.glu opengl ui ui.gadgets.slate
       combinators.lib vars
       random-weighted colors.hsv cfdg.gl ;

IN: cfdg

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! hsba { hue saturation brightness alpha }

: <hsba> 4array ;

VAR: color

! ( -- val )

: hue>>        0 color> nth ;
: saturation>> 1 color> nth ;
: brightness>> 2 color> nth ;
: alpha>>      3 color> nth ;

! ( val -- )

: >>hue        0 color> set-nth ;
: >>saturation 1 color> set-nth ;
: >>brightness 2 color> set-nth ;
: >>alpha      3 color> set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hsva>rgba ( hsva -- rgba ) [ 3 head hsv>rgb ] [ peek ] bi add ;

: gl-set-hsba ( hsva -- ) hsva>rgba gl-color ;

: gl-clear-hsba ( hsva -- ) hsva>rgba gl-clear ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! if (adjustment < 0)
!   base + base * adjustment

! if (adjustment > 0)
!   base + (1 - base) * adjustment

: adjust ( val num -- val ) dup 0 > [ 1 pick - * + ] [ dupd * + ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hue ( num -- ) hue>> + 360 mod >>hue ;

: saturation ( num -- ) saturation>> swap adjust >>saturation ;
: brightness ( num -- ) brightness>> swap adjust >>brightness ;
: alpha      ( num -- ) alpha>>      swap adjust >>alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: h   hue ;
: sat saturation ;
: b   brightness ;
: a   alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: color-stack

: init-color-stack ( -- ) V{ } clone >color-stack ;

: push-color ( -- ) color> color-stack> push   color> clone >color ;

: pop-color ( -- ) color-stack> pop dup >color gl-set-hsba ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: double-nth* ( c-array indices -- seq ) swap [ double-nth ] curry map ;

: check-size ( modelview -- num ) { 0 1 4 5 } double-nth* [ abs ] map biggest ;

VAR: threshold

: iterate? ( -- ? ) get-modelview-matrix check-size threshold> > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! cos 2a   sin 2a  0  0
! sin 2a  -cos 2a  0  0
!      0        0  1  0
!      0        0  0  1

! column major order

: gl-flip ( angle -- ) deg>rad dup dup dup
  [ 2 * cos ,   2 * sin ,       0 ,   0 ,
    2 * sin ,	2 * cos neg ,   0 ,   0 ,
          0 ,             0 ,   1 ,   0 , 
	  0 ,		  0 ,	0 ,   1 , ]
  { } make >c-double-array glMultMatrixd ;

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

: size* ( scale-x scale-y -- ) 1 glScaled ;

: rotate ( angle -- ) 0 0 1 glRotated ;

: x ( x -- ) 0 0 glTranslated ;

: y ( y -- ) 0 swap 0 glTranslated ;

: flip ( angle -- ) gl-flip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: s  size ;
: s* size* ;
: r  rotate ;
: f  flip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: do ( quot -- )
  push-modelview-matrix
  push-color
  call
  pop-modelview-matrix
  pop-color ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: recursive ( quot -- ) iterate? swap when ;

: multi ( seq -- ) random-weighted* call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: background

: set-initial-background ( -- ) { 0 0 1 1 } clone >color ;

: set-background ( -- )
  set-initial-background
  background> call
  color> gl-clear-hsba ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: rewrite-closures ;

VAR: viewport ! { left width bottom height }

VAR: start-shape

: set-initial-color ( -- ) { 0 0 0 1 } clone >color ;

: display ( -- )

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

  set-initial-color

  color> gl-set-hsba

  start-shape> call ;

: cfdg-window* ( -- )
  [ display ] closed-quot <slate>
  { 500 500 } over set-slate-dim
  dup "CFDG" open-window ;

: cfdg-window ( -- ) [ cfdg-window* ] with-ui ;