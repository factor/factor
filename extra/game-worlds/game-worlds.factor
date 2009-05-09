USING: accessors game-input game-loop kernel math ui.gadgets
ui.gadgets.worlds ui.gestures ;
IN: game-worlds

TUPLE: game-world < world
    game-loop
    { tick-slice float initial: 0.0 } ;

GENERIC: tick-length ( world -- millis )

M: game-world draw*
    swap >>tick-slice draw-world ;

M: game-world begin-world
    dup [ tick-length ] [ ] bi <game-loop> [ >>game-loop ] keep start-loop
    drop
    open-game-input ;

M: game-world end-world
    close-game-input
    [ [ stop-loop ] when* f ] change-game-loop
    drop ;

M: game-world focusable-child* drop t ;

