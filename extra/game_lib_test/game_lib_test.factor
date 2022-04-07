USING: accessors sequences kernel opengl game_lib.ui colors  ui.gadgets game_lib.board assocs calendar timers ;

IN: game_lib_test

: board ( -- board )
    10 10 make-board 
    { 0 0 } COLOR: blue add-to-cell ;

: display-window ( -- )
    { 400 400 } init-window
    board 2 seconds gravity-on
    { } 1sequence create-board
    display ;

MAIN: display-window