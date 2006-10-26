! Copyright (C) 2006 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
USING: alien cpu-8080 errors generic io kernel kernel-internals
math namespaces sequences styles threads gadgets gadgets opengl arrays 
concurrency ;
IN: space-invaders

TUPLE: space-invaders port1 port2i port2o port3o port4lo port4hi port5o bitmap ;

: dip ( x y quot -- y )
  #! Showing my Joy roots...
  swap >r call r> ; inline

: dipd ( x y z quot -- y z )
  #! Showing my Joy roots...
  -rot >r >r call r> r> ; inline  

: game-width 224  ; inline
: game-height 256 ; inline

: make-opengl-bitmap ( -- array )
  game-height game-width 3 * * "char" <c-array> ;

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
  
C: space-invaders ( -- cpu )
  [ <cpu> swap set-delegate ] keep
  [ make-opengl-bitmap swap set-space-invaders-bitmap ] keep
  [ reset ] keep ;

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
  {
    { [ over 1 = ] [ nip read-port1 ] }
    { [ over 2 = ] [ nip read-port2 ] }
    { [ over 3 = ] [ nip read-port3 ] }
    { [ t ]        [ 2drop 0 ] }    
  } cond ;

: write-port2 ( value cpu -- )
  #! Setting this value affects the value read from port 3
  set-space-invaders-port2o ;

: write-port3 ( value cpu -- )
  #! Connected to the sound hardware
  #! Bit 0 = spaceship sound (looped)
  #! Bit 1 = Shot 
  #! Bit 2 = Your ship hit
  #! Bit 3 = Invader hit
  #! Bit 4 = Extended play sound
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
  set-space-invaders-port5o ;

M: space-invaders write-port ( value port cpu -- )
  #! Write a byte to the hardware port, where 'port' is
  #! an 8-bit value.  
  {
    { [ over 2 = ] [ nip write-port2 ] }
    { [ over 3 = ] [ nip write-port3 ] }
    { [ over 4 = ] [ nip write-port4 ] }
    { [ over 5 = ] [ nip write-port5 ] }
    { [ t ]        [ 3drop ] }
  } cond ;

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
    { T{ key-down f f "ESCAPE" }    [ t swap set-invaders-gadget-quit? ] }
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

C: invaders-gadget ( cpu -- gadget ) 
  [ set-invaders-gadget-cpu ] keep
  [ f swap set-invaders-gadget-quit? ] keep
  [ delegate>gadget ] keep ;

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
 [ f swap set-invaders-gadget-quit? ] keep
 [ millis swap invaders-process ] spawn 2drop ;

M: invaders-gadget ungraft* ( gadget -- )
 t swap set-invaders-gadget-quit? ;

: run ( -- )  
  <space-invaders> "invaders.rom" over load-rom <invaders-gadget> 
  "Space Invaders" open-titled-window ;
