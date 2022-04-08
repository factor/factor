USING: accessors sequences kernel opengl game_lib.ui colors ui.gadgets.tracks ui.gestures ui.gadgets game_lib.board assocs calendar timers ;

IN: game_lib_test

TUPLE: window < track focusable-child-number ;

: board-init ( -- board )
    10 10 make-board 
    { 0 0 } COLOR: blue add-to-cell ;

: <window> ( -- gadget )
    horizontal window new-track 
    { 400 400 } init-window T{ key-down f f "RIGHT" } [ dup board>> first { 0 0 } { 1 0 } move-entire-cell drop relayout ] new-gesture
    board-init { } 1sequence  create-board ! board gadget with a board inside
    f track-add
    { 400 400 } init-window T{ key-down f f "RIGHT" } [ dup board>> first { 0 0 } { 1 0 } move-entire-cell drop relayout ] new-gesture
    board-init { } 1sequence create-board 
    f track-add ; 

 : display-window ( -- )
    ! { 400 400 } init-window
    ! board 2 seconds gravity-on ! returns gadget and board 
    ! { } 1sequence create-board ! returns a gadget
    <window>  
    display ;

! M: window focusable-child* children>> focusable-child-number nth ;



MAIN: display-window