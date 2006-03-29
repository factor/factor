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
lists math namespaces sequences styles threads gadgets gadgets-layouts opengl arrays ;
IN: space-invaders

TUPLE: space-invaders port1 port2i port2o port3o port4lo port4hi port5o bitmap ;

SYMBOL: bitmap

: make-opengl-bitmap ( -- array )
  256 224 3 * * "char" <c-array> ;

: bitmap-index ( x y -- index )
  224 3 * * swap 3 * + ;

: set-bitmap-pixel ( color x y array -- )
  >r bitmap-index r> ( color index array -- )
  [ >r >r first r> r> set-uchar-nth ] 3keep
  [ >r >r second r> 1 + r> set-uchar-nth ] 3keep
  >r >r third r> 2 + r> set-uchar-nth ;

: get-bitmap-pixel ( x y array -- )
  >r bitmap-index r> ( index array -- )
  [ uint-nth ] 2keep
  [ >r 1 + r> uchar-nth ] 2keep
  >r 2 + r> uchar-nth 3array ;
  
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

TUPLE: invaders-gadget cpu ;

C: invaders-gadget dup delegate>gadget ;


: do-draw2 ( gadget -- )
  0 0 glRasterPos2i
  1.0 -1.0 glPixelZoom
  >r 224 256 GL_RGB GL_UNSIGNED_BYTE r>
  invaders-gadget-cpu space-invaders-bitmap glDrawPixels ;
  
M: invaders-gadget draw-gadget* ( gadget -- )
  do-draw2 ;

M: invaders-gadget pref-dim* drop { 224 256 0 0 } ;

: sync-frame ( millis -- millis )
  #! Sleep until the time for the next frame arrives.
  1000 60 / >fixnum + millis - dup 0 > [ sleep ] [ drop ] if millis ;

: (event-loop) ( millis gadget -- )
  >r sync-frame r> 
  dup invaders-gadget-cpu gui-frame
  dup relayout-1
  (event-loop) ;
  
: event-loop ( gadget -- )
  [
    dup invaders-gadget-cpu space-invaders-bitmap bitmap set
    millis swap (event-loop) 
  ] with-scope ;


: black { 0 0 0 } ;
: white { 255 255 255 } ;

: addr>xy ( addr -- x y )
  #! Convert video RAM address to base X Y value
  HEX: 2400 - ( n )
  dup HEX: 1f bitand 8 * 255 swap - ( n y )
  swap -5 shift swap ;

: plot-bitmap-pixel ( x y color -- )
  -rot bitmap get set-bitmap-pixel ;

: plot-bitmap-bits ( x y byte bit -- )
  dup swapd -1 * shift 1 bitand 0 =
  [ ( x y bit -- ) - black ] [ - white ] if
  plot-bitmap-pixel ;

: do-bitmap-update ( value addr -- )
  addr>xy rot ( x y value )
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
    drop do-bitmap-update
  ] [
    3drop
  ] if ;

: run ( -- )  
  <space-invaders> "invaders.rom" over load-rom
  <invaders-gadget> [ set-invaders-gadget-cpu ] keep 
  dup "Space Invaders" open-window 
  [ event-loop ] cons in-thread ;