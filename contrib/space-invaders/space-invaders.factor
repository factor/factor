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
  [ bitmap-index ] dip ( color index array )
  [ [ first ] dipd set-uchar-nth ] 3keep
  [ [ second ] dipd [ 1 + ] dip set-uchar-nth ] 3keep
  [ third ] dipd [ 2 + ] dip set-uchar-nth ;

: get-bitmap-pixel ( point array -- color )
  #! Point is a {x y}. color is a {r g b} 
  [ bitmap-index ] dip
  [ uint-nth ] 2keep
  [ [ 1 + ] dip uchar-nth ] 2keep
  [ 2 + ] dip uchar-nth 3array ;
  
C: space-invaders ( cpu -- cpu )
  [ <cpu> swap set-delegate ] keep
  [ make-opengl-bitmap swap set-space-invaders-bitmap ] keep
  [ reset ] keep ;

M: space-invaders read-port ( port cpu -- byte )
  #! Read a byte from the hardware port. 'port' should
  #! be an 8-bit value.
  {
    { [ over 1 = ] [ nip [ space-invaders-port1 dup HEX: FE bitand ] keep set-space-invaders-port1 ] }
    { [ over 2 = ] [ nip [ space-invaders-port2i HEX: 8F bitand ] keep space-invaders-port1 HEX: 70 bitand bitor ] }
    { [ over 3 = ] [ nip [ space-invaders-port4hi 8 shift ] keep [ space-invaders-port4lo bitor ] keep space-invaders-port2o shift -8 shift HEX: FF bitand ] }
    { [ t ] [ 2drop 0 ] }    
  } cond ;

M: space-invaders write-port ( value port cpu -- )
  #! Write a byte to the hardware port, where 'port' is
  #! an 8-bit value.  
  {
    { [ over 2 = ] [ nip set-space-invaders-port2o ] }
    { [ over 3 = ] [ nip set-space-invaders-port3o ] }
    { [ over 4 = ] [ nip [ space-invaders-port4hi ] keep [ set-space-invaders-port4lo ] keep set-space-invaders-port4hi ] }
    { [ over 5 = ] [ nip set-space-invaders-port5o ] }
    { [ over 6 = ] [ 3drop ] }
    { [ t ] [ 3drop "Invalid port write" throw ] }
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
!  0 sleep
  [ read-instruction ] keep ( n cpu )
  over get-cycles over inc-cycles
  [ swap instructions dispatch ] keep  
  [ cpu-pc HEX: FFFF bitand ] keep 
  set-cpu-pc ;

: gui-frame/2 ( cpu -- )
  [ gui-step ] keep
  [ cpu-cycles ] keep
  over 16667 < [ ( cycles cpu )
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

TUPLE: invaders-gadget cpu process ;

TUPLE: coin-down-msg ;
TUPLE: coin-up-msg ;
TUPLE: player1-down-msg ;
TUPLE: player1-up-msg ;
TUPLE: player2-down-msg ;
TUPLE: player2-up-msg ;
TUPLE: fire-down-msg ;
TUPLE: fire-up-msg ;
TUPLE: left-down-msg ;
TUPLE: left-up-msg ;
TUPLE: right-down-msg ;
TUPLE: right-up-msg ;

: coin-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <coin-down-msg> over send [ 10 sleep <coin-up-msg> swap send ] spawn drop  ;

: player1-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <player1-down-msg> over send [ 10 sleep <player1-up-msg> swap send ] spawn drop ;

: player2-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <player2-down-msg> over send [ 10 sleep <player2-up-msg> swap send ] spawn drop ;

: fire-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <fire-down-msg> over send [ 10 sleep <fire-up-msg> swap send ] spawn drop ;

: left-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <left-down-msg> over send [ 10 sleep <left-up-msg> swap send ] spawn drop ;

: right-key-pressed ( process -- )
  #! Workaround lack of up event from gui.
  <right-down-msg> over send [ 10 sleep <right-up-msg> swap send ] spawn drop ;

: set-key-actions ( gadget -- )
!  H{
!    { [ "ESCAPE" ] [ invaders-gadget-process "stop" swap send ] }
!    { [ "BACKSPACE" ] [ invaders-gadget-process coin-key-pressed ] }
!    { [ "1" ] [ invaders-gadget-process player1-key-pressed ] }
!    { [ "2" ] [ invaders-gadget-process player2-key-pressed ] }
!    { [ "UP" ] [ invaders-gadget-process fire-key-pressed ] }
!    { [ "LEFT" ] [ invaders-gadget-process left-key-pressed ] }
!    { [ "RIGHT" ] [ invaders-gadget-process right-key-pressed ] }
!  } set-gestures 
  drop ;

C: invaders-gadget ( gadget -- )
  dup delegate>gadget 
  dup set-key-actions ;

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
  HEX: 2400 - ( n )
  dup HEX: 1f bitand 8 * 255 swap - ( n y )
  swap -5 shift swap 2array ;

: plot-bitmap-pixel ( bitmap point color -- )
  #! point is a {x y}. color is a {r g b}.
  swap rot set-bitmap-pixel ;

: within ( n a b - bool )
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

GENERIC: handle-invaders-message ( gadget message -- quit? )

! Any unknown message quits the process
M: object handle-invaders-message ( gadget message -- quit? )
  2drop t ;

M: coin-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 1 bitor ] keep 
  set-space-invaders-port1 f ;

M: coin-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 1 - bitand ] keep 
  set-space-invaders-port1 f ;

M: player1-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 4 bitor ] keep 
  set-space-invaders-port1 f ;

M: player1-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 4 - bitand ] keep 
  set-space-invaders-port1 f ;

M: player2-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 2 bitor ] keep 
  set-space-invaders-port1 f ;

M: player2-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 2 - bitand ] keep 
  set-space-invaders-port1 f ;

M: fire-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 HEX: 10 bitor ] keep 
  set-space-invaders-port1 f ;

M: fire-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 HEX: 10 - bitand ] keep 
  set-space-invaders-port1 f ;

M: left-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 HEX: 20 bitor ] keep 
  set-space-invaders-port1 f ;

M: left-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 HEX: 20 - bitand ] keep 
  set-space-invaders-port1 f ;

M: right-down-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 HEX: 40 bitor ] keep 
  set-space-invaders-port1 f ;

M: right-up-msg handle-invaders-message ( gadget message -- quit? )
  drop invaders-gadget-cpu 
  [ space-invaders-port1 255 HEX: 40 - bitand ] keep 
  set-space-invaders-port1 f ;

: sync-frame ( millis -- millis )
  #! Sleep until the time for the next frame arrives.
  1000 60 / >fixnum + millis - dup 0 > [ sleep ] [ drop ] if millis ;

: invaders-process ( millis gadget -- )
  #! Run a space invaders gadget inside a 
  #! concurrent process. Messages can be sent to
  #! signal key presses, etc.
  [
    [ sync-frame ] dip
    dup invaders-gadget-cpu gui-frame
    dup relayout-1
  ] while-no-messages 
  dup receive handle-invaders-message [ invaders-process ] unless ;

: run ( -- process )  
  <space-invaders> "invaders.rom" over load-rom
  <invaders-gadget> [ set-invaders-gadget-cpu ] keep   
  dup "Space Invaders" open-titled-window 
  dup [ millis swap invaders-process ] curry spawn 
  swap dupd set-invaders-gadget-process ;

: runx ( -- process )  
  <space-invaders> "invaders.rom" over load-rom
  <invaders-gadget> [ set-invaders-gadget-cpu ] keep   
  dup "Space Invaders" open-titled-window 
  dup "a" set invaders-gadget-cpu 1000 [ dup gui-frame "a" get relayout-1 ] times drop ;