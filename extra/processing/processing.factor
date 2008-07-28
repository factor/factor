
USING: kernel namespaces threads combinators sequences arrays
       math math.functions math.ranges random
       opengl.gl opengl.glu vars multi-methods generalizations shuffle
       ui
       ui.gestures
       ui.gadgets
       combinators
       combinators.lib
       combinators.cleave
       rewrite-closures fry accessors newfx
       processing.gadget math.geometry.rect
       processing.shapes
       colors ;
       
IN: processing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2random ( a b -- num ) 2dup swap - 100 / <range> random ;

: 1random ( b -- num ) 0 swap 2random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chance ( fraction -- ? ) 0 1 2random > ;

: percent-chance ( percent -- ? ) 100 / chance ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : at-fraction ( seq fraction -- val ) over length 1- * nth-at ;

: at-fraction ( seq fraction -- val ) over length 1- * at ;

: at-fraction-of ( fraction seq -- val ) swap at-fraction ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: canonical-color-value ( obj -- color )

METHOD: canonical-color-value { number } dup dup 1 rgba boa ;

METHOD: canonical-color-value { array }
   dup length
   {
     { 2 [ first2 >r dup dup r> rgba boa ] }
     { 3 [ first3 1             rgba boa ] }
     { 4 [ first4               rgba boa ] }
   }
   case ;

! METHOD: canonical-color-value { rgba }
!   { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave 4array ;

METHOD: canonical-color-value { color } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fill   ( value -- ) canonical-color-value >fill-color   ;
: stroke ( value -- ) canonical-color-value >stroke-color ;

! : no-fill   ( -- ) 0 fill-color>   set-fourth ;
! : no-stroke ( -- ) 0 stroke-color> set-fourth ;

: no-fill   ( -- ) fill-color>   0 >>alpha drop ;
: no-stroke ( -- ) stroke-color> 0 >>alpha drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: stroke-weight ( w -- ) glLineWidth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : quad-vertices ( x1 y1 x2 y2 x3 y3 x4 y4 -- )
!   GL_POLYGON glBegin
!     glVertex2d
!     glVertex2d
!     glVertex2d
!     glVertex2d
!   glEnd ;

! : quad ( x1 y1 x2 y2 x3 y3 x4 y4 -- )

!   8 ndup

!   GL_FRONT_AND_BACK GL_FILL glPolygonMode
!   fill-color> set-color

!   quad-vertices
  
!   GL_FRONT_AND_BACK GL_LINE glPolygonMode
!   stroke-color> set-color

!   quad-vertices ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : ellipse-disk ( x y width height -- )
!   glPushMatrix
!     >r >r
!     0 glTranslated
!     r> r> 1 glScaled
!     gluNewQuadric
!       dup 0 0.5 20 1 gluDisk
!     gluDeleteQuadric
!   glPopMatrix ;

! : ellipse-center ( x y width height -- )

!   4dup

!   GL_FRONT_AND_BACK GL_FILL glPolygonMode
!   stroke-color> set-color

!   ellipse-disk

!   GL_FRONT_AND_BACK GL_FILL glPolygonMode
!   fill-color> set-color

!   [ 2 - ] bi@ ! [ stroke-width 1+ - ] bi@

!   ellipse-disk ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! SYMBOL: CENTER
! SYMBOL: RADIUS
! SYMBOL: CORNER
! SYMBOL: CORNERS

! SYMBOL: ellipse-mode-value

! : ellipse-mode ( val -- ) ellipse-mode-value set ;

! : ellipse-radius ( x y hori vert -- ) [ 2 * ] bi@ ellipse-center ;

! : ellipse-corner ( x y width height -- )
!   [ drop nip     2 / + ] 4keep
!   [ nip rot drop 2 / + ] 4keep
!   [ >r >r 2drop r> r>  ] 4keep
!   4drop
!   ellipse-center ;

! : ellipse-corners ( x1 y1 x2 y2 -- )
!   [ drop nip     + 2 /    ] 4keep
!   [ nip rot drop + 2 /    ] 4keep
!   [ drop nip     - abs 1+ ] 4keep
!   [ nip rot drop - abs 1+ ] 4keep
!   4drop
!   ellipse-center ;

! : ellipse ( a b c d -- )
!   ellipse-mode-value get
!     {
!       { CENTER  [ ellipse-center ] }
!       { RADIUS  [ ellipse-radius ] }
!       { CORNER  [ ellipse-corner ] }
!       { CORNERS [ ellipse-corners ] }
!     }
!   case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: background ( value -- )

METHOD: background { number }
   dup dup 1 glClearColor
   GL_COLOR_BUFFER_BIT glClear ;

METHOD: background { array }
   dup length
   {
     { 2 [ first2 >r dup dup r> glClearColor GL_COLOR_BUFFER_BIT glClear ] }
     { 3 [ first3 1             glClearColor GL_COLOR_BUFFER_BIT glClear ] }
     { 4 [ first4               glClearColor GL_COLOR_BUFFER_BIT glClear ] }
   }
   case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: translate ( x y -- ) 0 glTranslated ;

: rotate ( angle -- ) 0 0 1 glRotated ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mouse ( -- point ) hand-loc get ;

: mouse-x ( -- x ) mouse first  ;
: mouse-y ( -- y ) mouse second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: frame-rate-value

: frame-rate ( fps -- ) 1000 swap / >frame-rate-value ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! VAR: slate

VAR: loop-flag

: defaults ( -- )
  0.8    background
  ! CENTER ellipse-mode
  60 frame-rate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: size-val

: size ( seq -- ) size-val set ;

: size* ( width height -- ) 2array size-val set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: setup-action
SYMBOL: draw-action

! : setup ( quot -- ) closed-quot setup-action set ;
! : draw  ( quot -- ) closed-quot draw-action  set ;

: setup ( quot -- ) setup-action set ;
: draw  ( quot -- ) draw-action  set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: key-down-action
SYMBOL: key-up-action

: key-down ( quot -- ) closed-quot key-down-action set ;
: key-up   ( quot -- ) closed-quot key-up-action   set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: button-down-action
SYMBOL: button-up-action

: button-down ( quot -- ) closed-quot button-down-action set ;
: button-up   ( quot -- ) closed-quot button-up-action   set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-processing-thread ( -- )
  loop-flag get not
    [
      loop-flag on
      [
        [ loop-flag get ]
        processing-gadget get frame-rate-value> '[ , relayout-1 , sleep ]
        [ ]
        while
      ]
      in-thread
    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-size ( -- size ) processing-gadget get rect-dim ;

: width  ( -- width  ) get-size first ;
: height ( -- height ) get-size second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: setup-called

: setup-called? ( -- ? ) setup-called get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )

  loop-flag off

  500 sleep

  <processing-gadget>
    size-val get >>pdim
    dup "Processing" open-window

    500 sleep

    defaults

    setup-called off

    [
      setup-called? not
        [
          setup-action get call
          setup-called on
        ]
        [
          draw-action get call
        ]
      if
    ]
      closed-quot >>action
    
    key-down-action get >>key-down
    key-up-action   get >>key-up

    button-down-action get >>button-down
    button-up-action   get >>button-up
    
  processing-gadget set

  start-processing-thread ;