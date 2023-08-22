USING: accessors sequences kernel opengl gamelib.ui colors math
math.vectors ui.gadgets.tracks ui.gestures ui.gadgets
gamelib.board assocs calendar timers ;

IN: multiple-board-demo

: board-init ( -- board )
    10 10 make-board 
    { 0 0 } COLOR: blue add-to-cell
    { } 1sequence ;

:: move ( board mov -- )
    board [ COLOR: blue = ] find-cell-pos :> player-pos
    player-pos mov v+ :> new-pos
    new-pos first 0 >= 
    new-pos first 10 < and
    [ board player-pos new-pos move-entire-cell drop ] when ;

:: first-gadget ( -- gadget )
    { 400 400 } init-board-gadget
    T{ key-down f f "RIGHT" } [ dup board>> first RIGHT move relayout ] new-gesture
    T{ key-down f f "LEFT" } [ dup board>> first LEFT move relayout ] new-gesture
    board-init add-board ;

:: second-gadget ( -- gadget )
    { 500 400 } init-board-gadget
    board-init add-board ;

:: display-window ( -- )
    first-gadget :> g1
    second-gadget :> g2
    { g1 g2 } horizontal 0 f <window> ! initalize two boards   
    display ;

MAIN: display-window
