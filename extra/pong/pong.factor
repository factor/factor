USING: accessors alien.c-types alien.data arrays calendar colors
combinators combinators.short-circuit flatland generalizations
grouping kernel locals math math.intervals math.order
math.rectangles math.vectors namespaces opengl opengl.gl
opengl.glu processing.shapes sequences sequences.generalizations
shuffle threads ui ui.gadgets ui.gestures ui.render ;
FROM: multi-methods => GENERIC: METHOD: ;
FROM: syntax => M: ;
IN: pong

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Inspired by this Ruby/Shoes version by why: http://gist.github.com/26431
!
! Which was based on this Nodebox version: http://billmill.org/pong.html
! by Bill Mill.
!
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: clamp-to-interval ( x interval -- x )
  [ from>> first max ] [ to>> first min ] bi ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <play-field> < <rectangle>    ;
TUPLE: <paddle>     < <rectangle>    ;

TUPLE: <computer>   < <paddle> { speed initial: 10 } ;

: computer-move-left  ( computer -- ) dup speed>> move-left-by  ;
: computer-move-right ( computer -- ) dup speed>> move-right-by ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <ball> < <vel>
  { diameter   initial: 20   }
  { bounciness initial:  1.2 }
  { max-speed  initial: 10   } ;

: above-lower-bound? ( ball field -- ? ) bottom 50 - above? ;
: below-upper-bound? ( ball field -- ? ) top    50 + below? ;

: in-bounds? ( ball field -- ? )
  {
    [ above-lower-bound? ]
    [ below-upper-bound? ]
  } 2&& ;

:: bounce-change-vertical-velocity ( BALL -- )

  BALL vel>> y neg
  BALL bounciness>> *

  BALL max-speed>> min

  BALL vel>> (y!) ;

:: bounce-off-paddle ( BALL PADDLE -- )

   BALL bounce-change-vertical-velocity

   BALL x   PADDLE center x   -   0.25 *   BALL vel>> (x!)

   PADDLE top   BALL pos>> (y!) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mouse-x ( -- x ) hand-loc get first ;

:: valid-paddle-interval ( PADDLE PLAY-FIELD -- interval )

   PLAY-FIELD [ left ] [ right ] bi PADDLE width - [a,b] ;

:: align-paddle-with-mouse ( PADDLE PLAY-FIELD -- )

   mouse-x

   PADDLE PLAY-FIELD valid-paddle-interval

   clamp-to-interval

   PADDLE pos>> (x!) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Protocol for drawing PONG objects

GENERIC: draw ( obj -- )

METHOD: draw { <paddle> } [ bottom-left ] [ dim>>          ] bi rectangle ;
METHOD: draw { <ball>   } [ pos>>       ] [ diameter>> 2 / ] bi circle    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <pong> < gadget paused field ball player computer ;

: pong ( -- gadget )
  <pong> new
  T{ <play-field> { pos {   0   0 } } { dim { 400 400 } } } clone >>field
  T{ <ball>       { pos {  50  50 } } { vel {   3   4 } } } clone >>ball
  T{ <paddle>     { pos { 200 396 } } { dim {  75   4 } } } clone >>player
  T{ <computer>   { pos { 200   0 } } { dim {  75   4 } } } clone >>computer ;

M: <pong> pref-dim* ( <pong> -- dim ) drop { 400 400 } ;
M: <pong> ungraft*  ( <pong> --     ) t >>paused drop  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <pong> draw-gadget* ( PONG -- )

  PONG computer>> draw
  PONG player>>   draw
  PONG ball>>     draw ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-system ( GADGET -- )

    GADGET field>>    :> FIELD
    GADGET ball>>     :> BALL
    GADGET player>>   :> PLAYER
    GADGET computer>> :> COMPUTER

    BALL FIELD in-bounds? [

        PLAYER FIELD align-paddle-with-mouse

        BALL 1 move-for

        ! computer reaction

        BALL COMPUTER to-the-left-of?  [ COMPUTER computer-move-left  ] when
        BALL COMPUTER to-the-right-of? [ COMPUTER computer-move-right ] when

        ! check if ball bounced off something

        ! player-blocked-ball?
        BALL PLAYER { [ above? ] [ in-between-horizontally? ] } 2&&
        [ BALL PLAYER   bounce-off-paddle  ] when

        ! computer-blocked-ball?
        BALL COMPUTER { [ below? ] [ in-between-horizontally? ] } 2&&
        [ BALL COMPUTER bounce-off-paddle  ] when

        ! bounced-off-wall?
        BALL FIELD in-between-horizontally? not
        [ BALL reverse-horizontal-velocity ] when

    ] [ t GADGET paused<< ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-pong-thread ( GADGET -- )
  f GADGET paused<<
  [
    [
      GADGET paused>>
      [ f ]
      [ GADGET iterate-system GADGET relayout-1 25 milliseconds sleep t ]
      if
    ]
    loop
  ]
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pong-window ( -- ) pong [ "PONG" open-window ] [ start-pong-thread ] bi ;

: pong-main ( -- ) [ pong-window ] with-ui ;

MAIN: pong-window
