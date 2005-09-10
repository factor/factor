IN: cpu-8080
USING: kernel lists sdl sdl-event sdl-gfx sdl-video math styles sequences io namespaces generic kernel-internals ;

: plot-bits ( h w byte bit -- )
  dup swapd -1 * shift 1 bitand 0 = [ ( h w bit -- )
    swap 8 * + surface get -rot swap black rgb pixelColor
  ] [
    swap 8 * + surface get -rot swap white rgb pixelColor
  ] ifte ;

: update-display ( cpu -- )
    224 [ ( cpu h -- h )
      32 [ ( cpu h w -- w )
        [ swap 32 * + HEX: 2400 + swap cpu-ram nth ] 3keep ( byte cpu h w )
        rot >r rot ( h w byte )
        [ 0 plot-bits ] 3keep
        [ 1 plot-bits ] 3keep
        [ 2 plot-bits ] 3keep
        [ 3 plot-bits ] 3keep
        [ 4 plot-bits ] 3keep
        [ 5 plot-bits ] 3keep
        [ 6 plot-bits ] 3keep
        [ 7 plot-bits ] 3keep
        drop r> -rot 
      ] repeat 
    ] repeat drop ;

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
    { [ dup "BACKSPACE" = ] [ drop [ cpu-port1 1 bitor ] keep set-cpu-port1 f ] }
    { [ dup 1 = ] [ drop [ cpu-port1 4 bitor ] keep set-cpu-port1 f ] }
    { [ dup "LCTRL" = ] [ drop [ cpu-port1 HEX: 10 bitor ] keep set-cpu-port1 f ] }
    { [ dup "LEFT" = ] [ drop [ cpu-port1 HEX: 20 bitor ] keep set-cpu-port1 f ] }
    { [ dup "RIGHT" = ] [ drop [ cpu-port1 HEX: 40 bitor ] keep set-cpu-port1 f ] }
    { [ t ] [ . drop f ] }
  } cond ;

M: key-up-event handle-si-event ( cpu event -- quit? )
  keyboard-event>binding last car ( cpu key )
  {
    { [ dup "ESCAPE" = ] [ 2drop t ] }
    { [ dup "BACKSPACE" = ] [ drop [ cpu-port1 255 1 - bitand ] keep set-cpu-port1 f ] }
    { [ dup 1 = ] [ drop [ cpu-port1 255 4 - bitand ] keep set-cpu-port1 f ] }
    { [ dup "LCTRL" = ] [ drop [ cpu-port1 255 HEX: 10 - bitand ] keep set-cpu-port1 f ] }
    { [ dup "LEFT" = ] [ drop [ cpu-port1 255 HEX: 20 - bitand ] keep set-cpu-port1 f ] }
    { [ dup "RIGHT" = ] [ drop [ cpu-port1 255 HEX: 40 - bitand ] keep set-cpu-port1 f ] }
    { [ t ] [ . drop f ] }
  } cond ;

: event-loop ( cpu event -- )
    dup SDL_PollEvent [
        2dup handle-si-event [
            2drop
        ] [
            event-loop
        ] ifte
    ] [
        [ over gui-frame ] with-surface
!        [
!          over update-display
!        ] with-surface
        event-loop
    ] ifte ; 

: addr>xy ( addr -- x y )
  #! Convert video RAM address to base X Y value
  HEX: 2400 - ( n )
  dup HEX: 1f bitand 8 * 255 swap - ( n y )
  swap -5 shift swap ;


: plot-bits2 ( x y byte bit -- )
  dup swapd -1 * shift 1 bitand 0 = [ ( x y bit -- )
    - surface get -rot black rgb pixelColor
  ] [
    - surface get -rot white rgb pixelColor
  ] ifte ;

: do-video-update ( value addr cpu -- )
  drop addr>xy rot ( x y value )
  [ 0 plot-bits2 ] 3keep
  [ 1 plot-bits2 ] 3keep
  [ 2 plot-bits2 ] 3keep
  [ 3 plot-bits2 ] 3keep
  [ 4 plot-bits2 ] 3keep
  [ 5 plot-bits2 ] 3keep
  [ 6 plot-bits2 ] 3keep
  7 plot-bits2 ;

: display ( -- )
  224 256 0 SDL_HWSURFACE [ 
   test-cpu [ do-video-update ] over set-cpu-display dup
   <event> event-loop
    SDL_Quit
  ] with-screen ;
