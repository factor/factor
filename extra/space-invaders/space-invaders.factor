! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: cpu.8080 openal math alien.c-types sequences kernel
       shuffle arrays io.files combinators kernel.private
       ui.gestures ui.gadgets ui.render opengl.gl system 
       threads concurrency match ui byte-arrays combinators.lib ;
IN: space-invaders

TUPLE: space-invaders port1 port2i port2o port3o port4lo port4hi port5o bitmap sounds looping? ;
: game-width 224  ; inline
: game-height 256 ; inline

: make-opengl-bitmap ( -- array )
  game-height game-width 3 * * <byte-array> ;

: bitmap-index ( point -- index )
  #! Point is a {x y}.
  first2 game-width 3 * * swap 3 * + ;

: set-bitmap-pixel ( color point array -- )
  #! 'color' is a {r g b}. Point is {x y}.
  [ bitmap-index ] dip ! color index array
  [ [ first ] dipd set-uchar-nth ] 3keep
  [ [ second ] dipd [ 1 + ] dip set-uchar-nth ] 3keep
  [ third ] dipd [ 2 + ] dip set-uchar-nth ;

: get-bitmap-pixel ( point array -- color )
  #! Point is a {x y}. color is a {r g b} 
  [ bitmap-index ] dip
  [ uint-nth ] 2keep
  [ [ 1 + ] dip uchar-nth ] 2keep
  [ 2 + ] dip uchar-nth 3array ;
  
: SOUND-SHOT         ( -- number ) 0 ;
: SOUND-UFO          ( -- number ) 1 ;
: SOUND-BASE-HIT     ( -- number ) 2 ;
: SOUND-INVADER-HIT  ( -- number ) 3 ;
: SOUND-WALK1        ( -- number ) 4 ;
: SOUND-WALK2        ( -- number ) 5 ;
: SOUND-WALK3        ( -- number ) 6 ;
: SOUND-WALK4        ( -- number ) 7 ;
: SOUND-UFO-HIT      ( -- number ) 8 ;

: init-sound ( index cpu filename  -- )
  swapd >r space-invaders-sounds nth AL_BUFFER r> 
  resource-path create-buffer-from-wav set-source-param ; 

: init-sounds ( cpu -- )
  init-openal
  [ 9 gen-sources swap set-space-invaders-sounds ] keep
  [ SOUND-SHOT        "extra/space-invaders/resources/Shot.wav" init-sound ] keep 
  [ SOUND-UFO         "extra/space-invaders/resources/Ufo.wav" init-sound ] keep 
  [ space-invaders-sounds SOUND-UFO swap nth AL_LOOPING AL_TRUE set-source-param ] keep
  [ SOUND-BASE-HIT    "extra/space-invaders/resources/BaseHit.wav" init-sound ] keep 
  [ SOUND-INVADER-HIT "extra/space-invaders/resources/InvHit.wav" init-sound ] keep 
  [ SOUND-WALK1       "extra/space-invaders/resources/Walk1.wav" init-sound ] keep 
  [ SOUND-WALK2       "extra/space-invaders/resources/Walk2.wav" init-sound ] keep 
  [ SOUND-WALK3       "extra/space-invaders/resources/Walk3.wav" init-sound ] keep 
  [ SOUND-WALK4       "extra/space-invaders/resources/Walk4.wav" init-sound ] keep 
  [ SOUND-UFO-HIT    "extra/space-invaders/resources/UfoHit.wav" init-sound ] keep
  f swap set-space-invaders-looping? ;

: <space-invaders> ( -- cpu )
  <cpu> space-invaders construct-delegate
  make-opengl-bitmap over set-space-invaders-bitmap
  [ init-sounds ] keep
  [ reset ] keep ;

: play-invaders-sound ( cpu sound -- )
  swap space-invaders-sounds nth source-play ;

: stop-invaders-sound ( cpu sound -- )
  swap space-invaders-sounds nth source-stop ;

: read-port1 ( cpu -- byte )
  #! Port 1 maps the keys for space invaders
  #! Bit 0 = coin slot
  #! Bit 1 = two players button
  #! Bit 2 = one player button
  #! Bit 4 = player one fire
  #! Bit 5 = player one left
  #! Bit 6 = player one right
  [ space-invaders-port1 dup HEX: FE bitand ] keep 
 set-space-invaders-port1 ;

: read-port2 ( cpu -- byte )
  #! Port 2 maps player 2 controls and dip switches
  #! Bit 0,1 = number of ships
  #! Bit 2   = mode (1=easy, 0=hard)
  #! Bit 4   = player two fire
  #! Bit 5   = player two left
  #! Bit 6   = player two right
  #! Bit 7   = show or hide coin info
  [ space-invaders-port2i HEX: 8F bitand ] keep 
  space-invaders-port1 HEX: 70 bitand bitor ;

: read-port3 ( cpu -- byte )
  #! Used to compute a special formula
  [ space-invaders-port4hi 8 shift ] keep 
  [ space-invaders-port4lo bitor ] keep 
  space-invaders-port2o shift -8 shift HEX: FF bitand ;

M: space-invaders read-port ( port cpu -- byte )
  #! Read a byte from the hardware port. 'port' should
  #! be an 8-bit value.
  swap {
    { 1 [ read-port1 ] }
    { 2 [ read-port2 ] }
    { 3 [ read-port3 ] }
    [ 2drop 0 ]
  } case ;

: write-port2 ( value cpu -- )
  #! Setting this value affects the value read from port 3
  set-space-invaders-port2o ;

: bit-newly-set? ( old-value new-value bit -- bool )
  tuck bit? >r bit? not r> and ;

: port3-newly-set? ( new-value cpu bit -- bool )
  >r space-invaders-port3o swap r> bit-newly-set? ;

: port5-newly-set? ( new-value cpu bit -- bool )
  >r space-invaders-port5o swap r> bit-newly-set? ;

: write-port3 ( value cpu -- )
  #! Connected to the sound hardware
  #! Bit 0 = spaceship sound (looped)
  #! Bit 1 = Shot 
  #! Bit 2 = Your ship hit
  #! Bit 3 = Invader hit
  #! Bit 4 = Extended play sound
  over 0 bit? over space-invaders-looping? not and [ 
    dup SOUND-UFO play-invaders-sound 
    t over set-space-invaders-looping?
  ] when 
  over 0 bit? not over space-invaders-looping? and [ 
    dup SOUND-UFO stop-invaders-sound 
    f over set-space-invaders-looping?
  ] when 
  2dup 0 port3-newly-set? [ dup SOUND-UFO  play-invaders-sound ] when
  2dup 1 port3-newly-set? [ dup SOUND-SHOT play-invaders-sound ] when
  2dup 2 port3-newly-set? [ dup SOUND-BASE-HIT play-invaders-sound ] when
  2dup 3 port3-newly-set? [ dup SOUND-INVADER-HIT play-invaders-sound ] when
  set-space-invaders-port3o ;

: write-port4 ( value cpu -- )
  #! Affects the value returned by reading port 3
  [ space-invaders-port4hi ] keep 
  [ set-space-invaders-port4lo ] keep 
  set-space-invaders-port4hi ;

: write-port5 ( value cpu -- )
  #! Plays sounds
  #! Bit 0 = invaders sound 1
  #! Bit 1 = invaders sound 2
  #! Bit 2 = invaders sound 3
  #! Bit 3 = invaders sound 4
  #! Bit 4 = spaceship hit 
  #! Bit 5 = amplifier enabled/disabled
  2dup 0 port5-newly-set? [ dup SOUND-WALK1 play-invaders-sound ] when
  2dup 1 port5-newly-set? [ dup SOUND-WALK2 play-invaders-sound ] when
  2dup 2 port5-newly-set? [ dup SOUND-WALK3 play-invaders-sound ] when
  2dup 3 port5-newly-set? [ dup SOUND-WALK4 play-invaders-sound ] when
  2dup 4 port5-newly-set? [ dup SOUND-UFO-HIT play-invaders-sound ] when
  set-space-invaders-port5o ;

M: space-invaders write-port ( value port cpu -- )
  #! Write a byte to the hardware port, where 'port' is
  #! an 8-bit value.  
  swap {
    { 2 [ write-port2 ] }
    { 3 [ write-port3 ] }
    { 4 [ write-port4 ] }
    { 5 [ write-port5 ] }
    [ 3drop ]
  } case ;

M: space-invaders reset ( cpu -- )
  [ delegate reset ] keep
  [ 0 swap set-space-invaders-port1 ] keep
  [ 0 swap set-space-invaders-port2i ] keep
  [ 0 swap set-space-invaders-port2o ] keep
  [ 0 swap set-space-invaders-port3o ] keep
  [ 0 swap set-space-invaders-port4lo ] keep
  [ 0 swap set-space-invaders-port4hi ] keep
  0 swap set-space-invaders-port5o ;

: gui-step ( cpu -- )
  [ read-instruction ] keep ! n cpu
  over get-cycles over inc-cycles
  [ swap instructions dispatch ] keep  
  [ cpu-pc HEX: FFFF bitand ] keep 
  set-cpu-pc ;

: gui-frame/2 ( cpu -- )
  [ gui-step ] keep
  [ cpu-cycles ] keep
  over 16667 < [ ! cycles cpu
    nip gui-frame/2
  ] [
    [ >r 16667 - r> set-cpu-cycles ] keep
    dup cpu-last-interrupt HEX: 10 = [
      HEX: 08 over set-cpu-last-interrupt HEX: 08 swap interrupt
    ] [
      HEX: 10 over set-cpu-last-interrupt HEX: 10 swap interrupt
    ] if     
  ] if ;

: gui-frame ( cpu -- )
  dup gui-frame/2 gui-frame/2 ;

: coin-down ( cpu -- )
  [ space-invaders-port1 1 bitor ] keep set-space-invaders-port1 ;

: coin-up ( cpu --  )
  [ space-invaders-port1 255 1 - bitand ] keep set-space-invaders-port1 ;

: player1-down ( cpu -- )
  [ space-invaders-port1 4 bitor ] keep set-space-invaders-port1 ;

: player1-up ( cpu -- )
  [ space-invaders-port1 255 4 - bitand ] keep set-space-invaders-port1 ;

: player2-down ( cpu -- )
  [ space-invaders-port1 2 bitor ] keep set-space-invaders-port1 ;

: player2-up ( cpu -- )
  [ space-invaders-port1 255 2 - bitand ] keep set-space-invaders-port1 ;

: fire-down ( cpu -- )
  [ space-invaders-port1 HEX: 10 bitor ] keep set-space-invaders-port1 ;

: fire-up ( cpu -- )
  [ space-invaders-port1 255 HEX: 10 - bitand ] keep set-space-invaders-port1 ;

: left-down ( cpu -- )
  [ space-invaders-port1 HEX: 20 bitor ] keep set-space-invaders-port1 ;

: left-up ( cpu -- )
  [ space-invaders-port1 255 HEX: 20 - bitand ] keep set-space-invaders-port1 ;

: right-down ( cpu -- )
  [ space-invaders-port1 HEX: 40 bitor ] keep set-space-invaders-port1 ;

: right-up ( cpu -- )
  [ space-invaders-port1 255 HEX: 40 - bitand ] keep set-space-invaders-port1 ;


TUPLE: invaders-gadget cpu quit? ;

invaders-gadget H{
    { T{ key-down f f "ESC" }    [ t swap set-invaders-gadget-quit? ] }
    { T{ key-down f f "BACKSPACE" } [ invaders-gadget-cpu coin-down ] }
    { T{ key-up   f f "BACKSPACE" } [ invaders-gadget-cpu coin-up ] }
    { T{ key-down f f "1" }         [ invaders-gadget-cpu player1-down ] }
    { T{ key-up   f f "1" }         [ invaders-gadget-cpu player1-up ] }
    { T{ key-down f f "2" }         [ invaders-gadget-cpu player2-down ] }
    { T{ key-up   f f "2" }         [ invaders-gadget-cpu player2-up ] }
    { T{ key-down f f "UP" }        [ invaders-gadget-cpu fire-down ] }
    { T{ key-up   f f "UP" }        [ invaders-gadget-cpu fire-up ] }
    { T{ key-down f f "LEFT" }      [ invaders-gadget-cpu left-down ] }
    { T{ key-up   f f "LEFT" }      [ invaders-gadget-cpu left-up ] }
    { T{ key-down f f "RIGHT" }     [ invaders-gadget-cpu right-down ] }
    { T{ key-up   f f "RIGHT" }     [ invaders-gadget-cpu right-up ] }
  } set-gestures 

: <invaders-gadget> ( cpu -- gadget ) 
  invaders-gadget construct-gadget
  [ set-invaders-gadget-cpu ] keep
  f over set-invaders-gadget-quit? ;

M: invaders-gadget pref-dim* drop { 224 256 0 } ;

M: invaders-gadget draw-gadget* ( gadget -- )
  0 0 glRasterPos2i
  1.0 -1.0 glPixelZoom
  >r 224 256 GL_RGB GL_UNSIGNED_BYTE r>
  invaders-gadget-cpu space-invaders-bitmap glDrawPixels ;

: black { 0 0 0 } ;
: white { 255 255 255 } ;
: green { 0 255 0 } ;
: red   { 255 0 0 } ;

: addr>xy ( addr -- point )
  #! Convert video RAM address to base X Y value. point is a {x y}.
  HEX: 2400 - ! n
  dup HEX: 1f bitand 8 * 255 swap - ! n y
  swap -5 shift swap 2array ;

: plot-bitmap-pixel ( bitmap point color -- )
  #! point is a {x y}. color is a {r g b}.
  swap rot set-bitmap-pixel ;

: within ( n a b -- bool )
  #! n >= a and n <= b
  rot tuck swap <= >r swap >= r> and ;

: get-point-color ( point -- color )
  #! Return the color to use for the given x/y position.
  first2
  {
    { [ dup 184 238 within pick 0 223 within and ] [ 2drop green ] }
    { [ dup 240 247 within pick 16 133 within and ] [ 2drop green ] }
    { [ dup 247 215 - 247 184 - within pick 0 223 within and ] [ 2drop red ] }
    { [ t ] [ 2drop white ] }
  } cond ;

: plot-bitmap-bits ( bitmap point byte bit -- )
  #! point is a {x y}.
  [ first2 ] dipd
  dup swapd -1 * shift 1 bitand 0 =
  [ - 2array ] dip
  [ black ] [ dup get-point-color ] if
  plot-bitmap-pixel ;

: do-bitmap-update ( bitmap value addr -- )
  addr>xy swap 
  [ 0 plot-bitmap-bits ] 3keep
  [ 1 plot-bitmap-bits ] 3keep
  [ 2 plot-bitmap-bits ] 3keep
  [ 3 plot-bitmap-bits ] 3keep
  [ 4 plot-bitmap-bits ] 3keep
  [ 5 plot-bitmap-bits ] 3keep
  [ 6 plot-bitmap-bits ] 3keep
  7 plot-bitmap-bits ;

M: space-invaders update-video ( value addr cpu -- )  
  over HEX: 2400 >= [
    space-invaders-bitmap -rot do-bitmap-update
  ] [
    3drop
  ] if ;

: sync-frame ( millis -- millis )
  #! Sleep until the time for the next frame arrives.
  1000 60 / >fixnum + millis - dup 0 >
  [ sleep ] [ drop yield ] if millis ;

: invaders-process ( millis gadget -- )
  #! Run a space invaders gadget inside a 
  #! concurrent process. Messages can be sent to
  #! signal key presses, etc.
  dup invaders-gadget-quit? [
    [ sync-frame ] dip
    [ invaders-gadget-cpu gui-frame ] keep
    [ relayout-1 ] keep
    invaders-process 
  ] unless ;

M: invaders-gadget graft* ( gadget -- )
 dup invaders-gadget-cpu init-sounds
 [ f swap set-invaders-gadget-quit? ] keep
 [ millis swap invaders-process ] spawn 2drop ;

M: invaders-gadget ungraft* ( gadget -- )
 t swap set-invaders-gadget-quit? ;

: (run) ( title cpu rom-info -- )
  over load-rom* <invaders-gadget> swap open-window ;

: run ( -- )  
  "Space Invaders" <space-invaders> {
    { HEX: 0000 "invaders/invaders.h" }
    { HEX: 0800 "invaders/invaders.g" }
    { HEX: 1000 "invaders/invaders.f" }
    { HEX: 1800 "invaders/invaders.e" }
  } [ (run) ] with-ui ;

MAIN: run
