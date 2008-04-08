
USING: kernel namespaces threads combinators sequences arrays
       math math.functions math.ranges random
       opengl.gl opengl.glu vars multi-methods shuffle
       ui
       ui.gestures
       ui.gadgets
       combinators
       combinators.lib
       combinators.cleave
       rewrite-closures fry accessors
       processing.color
       processing.gadget ;
       
IN: processing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2random ( a b -- num ) 2dup swap - 100 / <range> random ;

: 1random ( b -- num ) 0 swap 2random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chance ( fraction -- ? ) 0 1 2random > ;

: percent-chance ( percent -- ? ) 100 / chance ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: fill-color
VAR: stroke-color

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: set-color ( value -- )

METHOD: set-color { number } dup dup glColor3d ;

METHOD: set-color { array }
   dup length
   {
     { 2 [ first2 >r dup dup r> glColor4d ] }
     { 3 [ first3 glColor3d ] }
     { 4 [ first4 glColor4d ] }
   }
   case ;

METHOD: set-color { rgba }
  { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave glColor4d ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fill   ( value -- )  >fill-color ;
: stroke ( value -- ) >stroke-color ;

: no-fill ( -- )
  fill-color>
    {
      { [ dup number? ] [ 0 2array fill ] }
      { [ t           ]
        [
          [ drop 0 ] [ length 1- ] [ ] tri set-nth
        ] }
    }
  cond ;

: no-stroke ( -- )
  stroke-color>
    {
      { [ dup number? ] [ 0 2array stroke ] }
      { [ t           ]
        [
          [ drop 0 ] [ length 1- ] [ ] tri set-nth
        ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: stroke-weight ( w -- ) glLineWidth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point* ( x y -- )
  stroke-color> set-color
  GL_POINTS glBegin
    glVertex2d
  glEnd ;

: point ( seq -- ) first2 point* ;

: line ( x1 y1 x2 y2 -- )
  stroke-color> set-color
  GL_LINES glBegin
    glVertex2d
    glVertex2d
  glEnd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: triangle ( x1 y1 x2 y2 x3 y3 -- )

  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  fill-color> set-color

  6 ndup
  
  GL_TRIANGLES glBegin
    glVertex2d
    glVertex2d
    glVertex2d
  glEnd

  GL_FRONT_AND_BACK GL_LINE glPolygonMode
  stroke-color> set-color

  GL_TRIANGLES glBegin
    glVertex2d
    glVertex2d
    glVertex2d
  glEnd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: quad-vertices ( x1 y1 x2 y2 x3 y3 x4 y4 -- )
  GL_POLYGON glBegin
    glVertex2d
    glVertex2d
    glVertex2d
    glVertex2d
  glEnd ;

: quad ( x1 y1 x2 y2 x3 y3 x4 y4 -- )

  8 ndup

  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  fill-color> set-color

  quad-vertices
  
  GL_FRONT_AND_BACK GL_LINE glPolygonMode
  stroke-color> set-color

  quad-vertices ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rect-vertices ( x y width height -- )
  GL_POLYGON glBegin
    [ 2drop                      glVertex2d ] 4keep
    [ drop swap >r + 1- r>       glVertex2d ] 4keep
    [ >r swap >r + 1- r> r> + 1- glVertex2d ] 4keep
    [ nip + 1-                   glVertex2d ] 4keep
    4drop
  glEnd ;

: rect ( x y width height -- )

  4dup

  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  fill-color> set-color

  rect-vertices

  GL_FRONT_AND_BACK GL_LINE glPolygonMode
  stroke-color> set-color

  rect-vertices ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ellipse-disk ( x y width height -- )
  glPushMatrix
    >r >r
    0 glTranslated
    r> r> 1 glScaled
    gluNewQuadric
      dup 0 0.5 20 1 gluDisk
    gluDeleteQuadric
  glPopMatrix ;

: ellipse-center ( x y width height -- )

  4dup

  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  stroke-color> set-color

  ellipse-disk

  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  fill-color> set-color

  [ 2 - ] bi@ ! [ stroke-width 1+ - ] bi@

  ellipse-disk ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: CENTER
SYMBOL: RADIUS
SYMBOL: CORNER
SYMBOL: CORNERS

SYMBOL: ellipse-mode-value

: ellipse-mode ( val -- ) ellipse-mode-value set ;

: ellipse-radius ( x y hori vert -- ) [ 2 * ] bi@ ellipse-center ;

: ellipse-corner ( x y width height -- )
  [ drop nip     2 / + ] 4keep
  [ nip rot drop 2 / + ] 4keep
  [ >r >r 2drop r> r>  ] 4keep
  4drop
  ellipse-center ;

: ellipse-corners ( x1 y1 x2 y2 -- )
  [ drop nip     + 2 /    ] 4keep
  [ nip rot drop + 2 /    ] 4keep
  [ drop nip     - abs 1+ ] 4keep
  [ nip rot drop - abs 1+ ] 4keep
  4drop
  ellipse-center ;

: ellipse ( a b c d -- )
  ellipse-mode-value get
    {
      { CENTER  [ ellipse-center ] }
      { RADIUS  [ ellipse-radius ] }
      { CORNER  [ ellipse-corner ] }
      { CORNERS [ ellipse-corners ] }
    }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: circle ( pos size -- ) [ first2 ] [ dup ] bi* ellipse ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: multi-methods ;

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

: mouse-x mouse first  ;
: mouse-y mouse second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: frame-rate-value

: frame-rate ( fps -- ) 1000 swap / >frame-rate-value ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

VAR: loop-flag

: defaults ( -- )
  0.8    background
  0      >stroke-color
  1      >fill-color
  CENTER ellipse-mode
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
    size-val get >>dim
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