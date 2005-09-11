IN: space-invaders
USING: cpu-8080 kernel lists sdl sdl-event sdl-gfx sdl-video math styles sequences io namespaces generic kernel-internals threads errors ;

TUPLE: space-invaders port1 port2i port2o port3o port4lo port4hi port5o ;

C: space-invaders ( cpu -- cpu )
  [ <cpu> swap set-delegate ] keep 
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
    ] ifte     
  ] ifte ;

: gui-frame ( cpu -- )
  dup gui-frame/2 gui-frame/2 ;

GENERIC: handle-si-event ( cpu event -- quit? )

M: object handle-si-event ( cpu event -- quit? )
  2drop f ;

M: quit-event handle-si-event ( cpu event -- quit? )
  2drop t ;

USE: prettyprint 

M: key-down-event handle-si-event ( cpu event -- quit? )
  keyboard-event>binding last car ( cpu key )
  {
    { [ dup "ESCAPE" = ] [ 2drop t ] }
    { [ dup "BACKSPACE" = ] [ drop [ space-invaders-port1 1 bitor ] keep set-space-invaders-port1 f ] }
    { [ dup 1 = ] [ drop [ space-invaders-port1 4 bitor ] keep set-space-invaders-port1 f ] }
    { [ dup 2 = ] [ drop [ space-invaders-port1 2 bitor ] keep set-space-invaders-port1 f ] }
    { [ dup "LCTRL" = ] [ drop [ space-invaders-port1 HEX: 10 bitor ] keep set-space-invaders-port1 f ] }
    { [ dup "LEFT" = ] [ drop [ space-invaders-port1 HEX: 20 bitor ] keep set-space-invaders-port1 f ] }
    { [ dup "RIGHT" = ] [ drop [ space-invaders-port1 HEX: 40 bitor ] keep set-space-invaders-port1 f ] }
    { [ t ] [ . drop f ] }
  } cond ;

M: key-up-event handle-si-event ( cpu event -- quit? )
  keyboard-event>binding last car ( cpu key )
  {
    { [ dup "ESCAPE" = ] [ 2drop t ] }
    { [ dup "BACKSPACE" = ] [ drop [ space-invaders-port1 255 1 - bitand ] keep set-space-invaders-port1 f ] }
    { [ dup 1 = ] [ drop [ space-invaders-port1 255 4 - bitand ] keep set-space-invaders-port1 f ] }
    { [ dup 2 = ] [ drop [ space-invaders-port1 255 2 - bitand ] keep set-space-invaders-port1 f ] }
    { [ dup "LCTRL" = ] [ drop [ space-invaders-port1 255 HEX: 10 - bitand ] keep set-space-invaders-port1 f ] }
    { [ dup "LEFT" = ] [ drop [ space-invaders-port1 255 HEX: 20 - bitand ] keep set-space-invaders-port1 f ] }
    { [ dup "RIGHT" = ] [ drop [ space-invaders-port1 255 HEX: 40 - bitand ] keep set-space-invaders-port1 f ] }
    { [ t ] [ . drop f ] }
  } cond ;

: sync-frame ( millis -- millis )
  #! Sleep until the time for the next frame arrives.
  1000 60 / >fixnum + millis - dup 0 > [ sleep ] [ drop ] ifte millis ;

: (event-loop) ( millis cpu event -- )
    dup SDL_PollEvent [
        2dup handle-si-event [
            3drop
        ] [
            (event-loop)
        ] ifte
    ] [
	>r >r sync-frame r> r>
        [ over gui-frame ] with-surface
        (event-loop)
    ] ifte ; 
  
: event-loop ( cpu event -- )
    millis -rot (event-loop) ;

: addr>xy ( addr -- x y )
  #! Convert video RAM address to base X Y value
  HEX: 2400 - ( n )
  dup HEX: 1f bitand 8 * 255 swap - ( n y )
  swap -5 shift swap ;

: within ( n a b - bool )
  #! n >= a and n <= b
  rot tuck swap <= >r swap >= r> and ;

: color ( x y -- color )
  #! Return the color to use for the given x/y position.
  {
    { [ dup 184 238 within pick 0 223 within and ] [ 2drop green ] }
    { [ dup 240 247 within pick 16 133 within and ] [ 2drop green ] }
    { [ dup 247 215 - 247 184 - within pick 0 223 within and ] [ 2drop red ] }
    { [ t ] [ 2drop white ] }
  } cond ;

: plot-bits ( x y byte bit -- )
  dup swapd -1 * shift 1 bitand 0 = [ ( x y bit -- )
    - surface get -rot black rgb pixelColor
  ] [
    - surface get -rot 2dup color rgb pixelColor
  ] ifte ;

: do-video-update ( value addr cpu -- )
  drop addr>xy rot ( x y value )
  [ 0 plot-bits ] 3keep
  [ 1 plot-bits ] 3keep
  [ 2 plot-bits ] 3keep
  [ 3 plot-bits ] 3keep
  [ 4 plot-bits ] 3keep
  [ 5 plot-bits ] 3keep
  [ 6 plot-bits ] 3keep
  7 plot-bits ;

M: space-invaders update-video ( value addr cpu -- )
  over HEX: 2400 >= [
    do-video-update
  ] [
    3drop
  ] ifte ;

: run ( -- )
  224 256 0 SDL_HWSURFACE [ 
   <space-invaders> "invaders.rom" over load-rom
   <event> event-loop
    SDL_Quit
  ] with-screen ;

