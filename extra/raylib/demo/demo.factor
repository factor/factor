! Copyright (C) 2019 Jack Lucas
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel math namespaces
raylib ;
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
    Vector2 boa player set ;

: check-axis-movement ( key-negative key-positive -- unit/f )
    [ is-key-down ] bi@ 2array {
        { { t f } [ -1.0 ] }
        { { f t } [  1.0 ] }
        [ drop f ]
    } case ;

: change-player-position ( -- )
    player get
    KEY_LEFT KEY_RIGHT check-axis-movement [ '[ _ 2.0 * + ] change-x ] when*
    KEY_UP KEY_DOWN check-axis-movement [ '[ _ 2.0 * + ] change-y ] when*
    drop ;

: render-loop ( -- )
    begin-drawing
    clear-window show-player-circle say-hello
    end-drawing ;

: main ( -- )
    make-window clear-window setup-game-vars
    [
        change-player-position
        render-loop
        window-should-close not
    ] loop close-window ;

MAIN: main
