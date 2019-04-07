! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: raylib.ffi kernel math.ranges sequences locals random combinators.random  math threads calendar namespaces accessors classes.struct combinators alien.enums ;
IN: raylib.demo 

: say-hello ( -- )
    "Hello, Factor!" 200 400 60 MAGENTA draw-text ;

: make-window ( -- )
    640 480 "Hello, Factor!" init-window
    60 set-target-fps ;

: clear-window ( -- )
    RAYWHITE clear-background  ;

! Save our players position in a dynamic var
SYMBOL: player

: show-player-circle ( -- )
    player get
    25.0 RED draw-circle-v ;
    
: setup-game-vars ( -- )
    get-screen-width 2 /
    get-screen-height 2 /
    Vector2 <struct-boa> player set ;

! Make this cleaner
: change-player-position ( -- )
    {
        { [ KEY_RIGHT enum>number is-key-down ] [ player get x>> 2.0 + player get x<<   ] }
        { [ KEY_LEFT enum>number is-key-down ] [ player get x>> -2.0 + player get x<<   ] }
        { [ KEY_DOWN enum>number is-key-down ] [ player get y>> 2.0 + player get y<<   ] }
        { [ KEY_UP   enum>number is-key-down ] [ player get y>> -2.0 +  player get y<<   ] }
        [  ] } cond ;

: render-loop ( -- )
    begin-drawing
    clear-window show-player-circle say-hello
    end-drawing ;

: main ( -- )
    make-window clear-window setup-game-vars
    [ change-player-position
      render-loop
      window-should-close not ] loop
    close-window
        ;
    
MAIN: main
   
