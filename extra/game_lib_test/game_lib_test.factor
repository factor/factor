USING: accessors sequences kernel opengl game_lib.ui colors ui.gadgets.tracks ui.gestures ui.gadgets game_lib.board assocs calendar timers ;

IN: game_lib_test

! TUPLE: window < track focusable-child-number ;

: board-init ( -- board )
    10 10 make-board 
    { 0 0 } COLOR: blue add-to-cell
    { } 1sequence ;

! :: <window> ( board-gadgets orientation fsn -- gadget )
    

!     orientation window new-track 

!     fsn >>focusable-child-number

!     board-gadgets  [ f track-add ] each ;

:: first-gadget ( -- gadget )
    { 400 400 } init-board-gadget
    T{ key-down f f "RIGHT" } [ dup board>> first { 0 0 } { 1 0 } move-entire-cell drop relayout ] new-gesture
    board-init add-board ;

:: second-gadget ( -- gadget )
    { 500 400 } init-board-gadget
    T{ key-down f f "RIGHT" } [ dup board>> first { 0 0 } { 1 0 } move-entire-cell drop relayout ] new-gesture
    board-init add-board ;

 :: display-window ( -- )
    first-gadget :> g1
    second-gadget :> g2
    { g1 g2 } horizontal 0 <window> ! initalize two boards   
    display ;

!  M: window focusable-child* dup children>> swap focusable-child-number>> swap nth ;



MAIN: display-window