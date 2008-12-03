
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

TUPLE: <pong> < gadget draw closed ;

M: <pong> pref-dim*    ( <pong> -- dim ) drop { 400 400 } ;
M: <pong> draw-gadget* ( <pong> --     ) draw>> call      ;
M: <pong> ungraft*     ( <pong> --     ) t >>closed drop  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-draw-closure ( -- closure )

  ! Establish some bindings

  [let | PLAY-FIELD [ T{ <play-field> { pos {  0  0 } } { dim { 400 400 } } } ]
         BALL       [ T{ <ball>       { pos { 50 50 } } { vel {   3   4 } } } ]

         PLAYER   [ T{ <paddle>   { pos { 200 396 } } { dim { 75 4 } } } ]
         COMPUTER [ T{ <computer> { pos { 200   0 } } { dim { 75 4 } } } ] |

    ! Define some internal words in terms of those bindings ...

    [wlet | align-player-with-mouse [ ( -- )
              PLAYER PLAY-FIELD align-paddle-with-mouse ]

            move-ball [ ( -- ) BALL 1 move-for ]

            player-blocked-ball? [ ( -- ? )
              BALL PLAYER { [ above? ] [ in-between-horizontally? ] } && ]

            computer-blocked-ball? [ ( -- ? )
              BALL COMPUTER { [ below? ] [ in-between-horizontally? ] } && ]

            bounce-off-wall? [ ( -- ? )
              BALL PLAY-FIELD in-between-horizontally? not ] |

      ! Note, we're returning a quotation.
      ! The quotation closes over the bindings established by the 'let'.
      ! Thus the name of the word 'make-draw-closure'.
      ! This closure is intended to be placed in the 'draw' slot of a
      ! <pong> gadget.
      
      [

        BALL PLAY-FIELD in-bounds?
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

            ! draw the objects
              
            COMPUTER draw
            PLAYER   draw
            BALL     draw
  
          ]
        when

      ] ] ] ( -- closure ) ; ! The trailing stack effect here is a workaround.
                             ! The stack effects in the wlet expression throw
                             ! off the effect for the whole word, so we reset
                             ! it to the correct one here.

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: pong-loop-step ( PONG -- ? )
  PONG closed>>
    [ f ]
    [ PONG relayout-1 25 milliseconds sleep t ]
  if ;

:: start-pong-thread ( PONG -- ) [ [ PONG pong-loop-step ] loop ] in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: play-pong ( -- )

  <pong> new-gadget
    make-draw-closure >>draw
  dup "PONG" open-window
    
  start-pong-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: play-pong-main ( -- ) [ play-pong ] with-ui ;

MAIN: play-pong-main