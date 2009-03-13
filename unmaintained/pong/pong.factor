
USING: kernel accessors locals math math.intervals math.order
       namespaces sequences threads
       ui
       ui.gadgets
       ui.gestures
       ui.render
       calendar
       multi-methods
       multi-method-syntax
       combinators.short-circuit.smart
       combinators.cleave.enhanced
       processing.shapes
       flatland ;

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
  } && ;

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

METHOD: draw ( <paddle> -- ) [ bottom-left ] [ dim>>          ] bi rectangle ;
METHOD: draw ( <ball>   -- ) [ pos>>       ] [ diameter>> 2 / ] bi circle    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: syntax ! Switch back to core 'TUPLE:' instead of the one provided
            ! by multi-methods

TUPLE: <pong> < gadget paused field ball player computer ;

: pong ( -- gadget )
  <pong> new-gadget
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

  [let | FIELD    [ GADGET field>>    ]
         BALL     [ GADGET ball>>     ]
         PLAYER   [ GADGET player>>   ]
         COMPUTER [ GADGET computer>> ] |

    [wlet | align-player-with-mouse [ ( -- )
              PLAYER FIELD align-paddle-with-mouse ]

            move-ball [ ( -- ) BALL 1 move-for ]

            player-blocked-ball? [ ( -- ? )
              BALL PLAYER { [ above? ] [ in-between-horizontally? ] } && ]

            computer-blocked-ball? [ ( -- ? )
              BALL COMPUTER { [ below? ] [ in-between-horizontally? ] } && ]

            bounce-off-wall? [ ( -- ? )
              BALL FIELD in-between-horizontally? not ]

            stop-game [ ( -- ) t GADGET (>>paused) ] |

      BALL FIELD in-bounds?
      [

        align-player-with-mouse

        move-ball

        ! computer reaction

        BALL COMPUTER to-the-left-of?  [ COMPUTER computer-move-left  ] when
        BALL COMPUTER to-the-right-of? [ COMPUTER computer-move-right ] when

        ! check if ball bounced off something
              
        player-blocked-ball?   [ BALL PLAYER   bounce-off-paddle  ] when
        computer-blocked-ball? [ BALL COMPUTER bounce-off-paddle  ] when
        bounce-off-wall?       [ BALL reverse-horizontal-velocity ] when
      ]
      [ stop-game ]
      if

  ] ] ( gadget -- ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-pong-thread ( GADGET -- )
  f GADGET (>>paused)
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