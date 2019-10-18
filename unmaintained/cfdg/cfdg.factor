
USING: kernel alien.c-types combinators namespaces make arrays
       sequences splitting
       math math.functions math.vectors math.trig
       opengl.gl opengl.glu opengl ui ui.gadgets.slate
       vars colors self self.slots
       random-weighted colors.hsv cfdg.gl accessors
       ui.gadgets.handler ui.gestures assocs ui.gadgets macros
       specialized-arrays.double ;

QUALIFIED: syntax

IN: cfdg

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SELF-SLOTS: hsva

: clear-color ( color -- ) gl-clear-color GL_COLOR_BUFFER_BIT glClear ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! if (adjustment < 0)
!   base + base * adjustment

! if (adjustment > 0)
!   base + (1 - base) * adjustment

: adjust ( val num -- val ) dup 0 > [ 1 pick - * + ] [ dupd * + ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hue ( num -- ) hue-> + 360 mod ->hue ;

: saturation ( num -- ) saturation-> swap adjust ->saturation ;
: brightness ( num -- ) value->      swap adjust ->value ;
: alpha      ( num -- ) alpha->      swap adjust ->alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: h   ( num -- ) hue ;
: sat ( num -- ) saturation ;
: b   ( num -- ) brightness ;
: a   ( num -- ) alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: color-stack

: init-color-stack ( -- ) V{ } clone >color-stack ;

: push-color ( -- ) self> color-stack> push   self> clone >self ;

: pop-color ( -- ) color-stack> pop dup >self gl-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : double-nth* ( c-array indices -- seq ) swap [ double-nth ] curry map ;

: double-nth* ( c-array indices -- seq )
  swap byte-array>double-array [ nth ] curry map ;

: check-size ( modelview -- num ) { 0 1 4 5 } double-nth* [ abs ] map supremum ;

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
    2 * sin ,   2 * cos neg ,   0 ,   0 ,
          0 ,             0 ,   1 ,   0 , 
          0 ,             0 ,   0 ,   1 , ]
  double-array{ } make underlying>> glMultMatrixd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: circle ( -- )
  self> gl-color
  gluNewQuadric dup 0 0.5 20 10 gluDisk gluDeleteQuadric ;

: triangle ( -- )
  self> gl-color
  GL_POLYGON glBegin
    0    0.577 glVertex2d
    0.5 -0.289 glVertex2d
   -0.5 -0.289 glVertex2d
  glEnd ;

: square ( -- )
  self> gl-color
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

: s  ( scale -- ) size ;
: s* ( scale-x scale-y -- ) size* ;
: r  ( angle -- ) rotate ;
: f  ( angle -- ) flip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: do ( quot -- )
  push-modelview-matrix
  push-color
  call
  pop-modelview-matrix
  pop-color ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: recursive ( quot -- ) iterate? swap when ; inline

: multi ( seq -- ) random-weighted* call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [rules] ( seq -- quot )
  [ unclip swap [ [ do ] curry ] map concat 2array ] map
  [ call-random-weighted ] swap prefix
  [ when ] swap prefix
  [ iterate? ] swap append ;

MACRO: rules ( seq -- quot ) [rules] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [rule] ( seq -- quot )
  [ [ do ] swap prefix ] map concat
  [ when ] swap prefix
  [ iterate? ] prepend ;

MACRO: rule ( seq -- quot ) [rule] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: background

: set-initial-background ( -- ) T{ hsva f 0 0 1 1 } clone >self ;

: set-background ( -- )
  set-initial-background
  background> call
  self> clear-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: rewrite-closures ;

VAR: viewport ! { left width bottom height }

VAR: start-shape

: set-initial-color ( -- ) T{ hsva f 0 0 0 1 } clone >self ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: dlist

! : build-model-dlist ( -- )
!   1 glGenLists dlist set
!   dlist get GL_COMPILE_AND_EXECUTE glNewList
!   start-shape> call
!   glEndList ;

: build-model-dlist ( -- )
  1 glGenLists dlist set
  dlist get GL_COMPILE_AND_EXECUTE glNewList

  set-initial-color

  self> gl-color

  start-shape> call
      
  glEndList ;

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

  dlist get not
    [ build-model-dlist ]
    [ dlist get glCallList ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: delete-dlist ( -- ) dlist get [ dlist get 1 glDeleteLists dlist off ] when ;

: cfdg-window* ( -- slate )
  C[ display ] <slate>
    { 500 500 }       >>pdim
    C[ delete-dlist ] >>ungraft
  dup "CFDG" open-window ;

: cfdg-window ( -- slate ) [ cfdg-window* ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: the-slate

: rebuild ( -- ) delete-dlist the-slate get relayout-1 ;

: <cfdg-gadget> ( -- slate )
  C[ display ] <slate>
    dup the-slate set
    { 500 500 } >>pdim
    C[ dlist get [ dlist get 1 glDeleteLists ] when ] >>ungraft
  <handler>
    H{ } clone
      T{ key-down f f "ENTER" } C[ drop rebuild ] swap pick set-at
      T{ button-down } C[ drop rebuild ] swap pick set-at
    >>table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: fry

: cfdg-window. ( quot -- )
  '[ [ @ <cfdg-gadget> "CFDG" open-window ] with-scope ] with-ui ;