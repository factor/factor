! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: raylib.ffi kernel math.ranges sequences locals random combinators.random  math threads calendar namespaces accessors classes.struct combinators alien.enums raylib.modules.gui ;
IN: raylib.gui-demo

: make-window ( -- )
    800 600 "Hello, Factor!" init-window
    60 set-target-fps ;

: button-rec ( -- button )
    50 50 100 100 Rectangle <struct-boa> ;

: white-background ( -- )
    RAYWHITE clear-background ;

: say-hello ( -- )
    "Hello Factor!" 4 4 30 RED draw-text ;

: set-button-style ( -- )
    BUTTON enum>number
    TEXT_ALIGNMENT enum>number
    GUI_TEXT_ALIGN_LEFT enum>number
    rl-gui-set-style ;

: draw-button ( -- )
    set-button-style
    button-rec "Button"
    rl-gui-button drop ;

: render-gui ( -- )
    rl-gui-lock
    draw-button
    rl-gui-unlock ;

: render-loop ( -- )
    begin-drawing white-background 
    say-hello render-gui end-drawing ;

: main ( -- )
    make-window
    [ render-loop
      window-should-close not ] loop
    close-window ;

