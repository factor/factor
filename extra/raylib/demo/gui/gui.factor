! Copyright (C) 2019 Jack Lucas
! See https://factorcode.org/license.txt for BSD license.

USING: alien.enums kernel raylib raygui ;

IN: raylib.demo.gui

: make-window ( -- )
    800 600 "Hello, Factor!" init-window
    60 set-target-fps ;

: button-rec ( -- button )
    50 50 100 100 Rectangle boa ;

: white-background ( -- )
    RAYWHITE clear-background ;

: say-hello ( -- )
    "Hello Factor!" 4 4 30 RED draw-text ;

: set-button-style ( -- )
    BUTTON enum>number
    TEXT_ALIGNMENT enum>number
    GUI_TEXT_ALIGN_LEFT enum>number
    gui-set-style ;

: draw-button ( -- )
    set-button-style
    button-rec "Button"
    gui-button drop ;

: render-gui ( -- )
    gui-lock
    draw-button
    gui-unlock ;

: render-loop ( -- )
    begin-drawing white-background
    say-hello render-gui end-drawing ;

: main ( -- )
    make-window [
        render-loop
        window-should-close not
    ] loop close-window ;

MAIN: main
