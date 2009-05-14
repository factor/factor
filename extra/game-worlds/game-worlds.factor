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
    open-game-input 
    dup [ tick-length ] [ ] bi <game-loop> [ >>game-loop ] keep start-loop
    drop ;

M: game-world end-world
    [ [ stop-loop ] when* f ] change-game-loop
    close-game-input
    drop ;

