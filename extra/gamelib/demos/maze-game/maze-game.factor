USING: accessors colors combinators gamelib.board gamelib.ui
kernel math math.vectors prettyprint sequences ui ui.gadgets
ui.gadgets.scrollers ui.gadgets.sliders ui.gadgets.tracks
ui.gestures ;

IN: gamelib.demos.maze-game

TUPLE: maze-gadget < track maze-scroller board-gadget ;

: board ( gadget -- gadget )
    17 17 make-board
    { 
        { 0  0 } { 1  0 } { 2  0 } { 3  0 } { 4  0 } { 5  0 } { 6  0 } { 7  0 } { 8  0 } { 9  0 } { 10  0 } { 11  0 } { 12  0 } { 13  0 } { 14  0 } { 15  0 } { 16  0 }
                                                                                { 8  1 }                                                                      { 16  1 }
        { 0  2 } { 1  2 } { 2  2 } { 3  2 } { 4  2 }          { 6  2 }          { 8  2 } { 9  2 } { 10  2 } { 11  2 } { 12  2 }           { 14  2 }           { 16  2 }                  
        { 0  3 }                                              { 6  3 }                                                { 12  3 }           { 14  3 }           { 16  3 }
        { 0  4 }          { 2  4 } { 3  4 } { 4  4 } { 5  4 } { 6  4 } { 7  4 } { 8  4 } { 9  4 } { 10  4 }           { 12  4 }           { 14  4 } { 15  4 } { 16  4 }
        { 0  5 }                            { 4  5 }                            { 8  5 }                              { 12  5 }                               { 16  5 }
        { 0  6 } { 1  6 } { 2  6 }          { 4  6 }          { 6  6 }          { 8  6 }          { 10  6 } { 11  6 } { 12  6 } { 13  6 } { 14  6 }           { 16  6 }
        { 0  7 }                            { 4  7 }          { 6  7 }          { 8  7 }                              { 12  7 }                               { 16  7 }
        { 0  8 }          { 2  8 } { 3  8 } { 4  8 } { 5  8 } { 6  8 }          { 8  8 } { 9  8 } { 10  8 }           { 12  8 }           { 14  8 }           { 16  8 }
        { 0  9 }                                              { 6  9 }                            { 10  9 }                               { 14  9 }           { 16  9 }
        { 0 10 } { 1 10 } { 2 10 } { 3 10 } { 4 10 }          { 6 10 }          { 8 10 }          { 10 10 } { 11 10 } { 12 10 } { 13 10 } { 14 10 }           { 16 10 }
        { 0 11 }          { 2 11 }                            { 6 11 }          { 8 11 }                                                  { 14 11 }           { 16 11 }
        { 0 12 }          { 2 12 } { 3 12 } { 4 12 } { 5 12 } { 6 12 }          { 8 12 }          { 10 12 } { 11 12 } { 12 12 } { 13 12 } { 14 12 }           { 16 12 }
        { 0 13 }                                              { 6 13 }          { 8 13 }                                                                      { 16 13 }
        { 0 14 }          { 2 14 } { 3 14 } { 4 14 } { 5 14 } { 6 14 }          { 8 14 } { 9 14 } { 10 14 } { 11 14 } { 12 14 } { 13 14 } { 14 14 } { 15 14 } { 16 14 }
        { 0 15 }                                                                                                                                              
        { 0 16 } { 1 16 } { 2 16 } { 3 16 } { 4 16 } { 5 16 } { 6 16 } { 7 16 } { 8 16 } { 9 16 } { 10 16 } { 11 16 } { 12 16 } { 13 16 } { 14 16 } { 15 16 } { 16 16 }
    } COLOR: black add-to-cells

    { 1 1 } COLOR: blue add-to-cell
    
    { } 1sequence add-board ;

:: bound-check ( new-pos -- ? )
    new-pos [ 0 >= ] all? 
    new-pos [ 17 < ] all? and ;

: can-move? ( board new-pos -- ? )
    get-cell is-empty? ;

:: move-window ( scroller move -- )
    {
        { [ move LEFT = ] [ scroller x>> -100 swap slide-by ] }
        { [ move RIGHT = ] [ scroller x>> 100 swap slide-by ] }
        { [ move DOWN = ] [ scroller y>> 100 swap slide-by ] }
        { [ move UP = ] [ scroller y>> -100 swap slide-by ] }
    } cond ;

:: move ( maze-gadget move -- ) 
    maze-gadget board-gadget>> board>> first :> board
    maze-gadget maze-scroller>> :> scroller
    board [ COLOR: blue = ] find-cell-pos :> player-pos
    player-pos move v+ :> new-pos
    
    new-pos bound-check ! check new pos is still inside of board
    [   
        board new-pos can-move? ! check if new pos is an empty space
        [   
            player-pos { 0 1 } = not player-pos { 16 15 } = not and ! check player isn't at edge of board
            [ 
                scroller move move-window
            ] when
            board player-pos new-pos move-entire-cell drop
        ] when
    ] when  
    maze-gadget relayout-1 ; 

maze-gadget H{
    { T{ key-down f f "RIGHT" } [ RIGHT move ] } 
    { T{ key-down f f "LEFT" } [ LEFT move ] }  
    { T{ key-down f f "UP" } [ UP move ] } 
    { T{ key-down f f "DOWN" } [ DOWN move ] } 
} set-gestures

: main ( -- gadget )
    vertical maze-gadget new-track
    { 1700 1700 } init-board-gadget
    board [ >>board-gadget ] keep
    <scroller> [ >>maze-scroller ] keep
    1 track-add ;

MAIN-WINDOW: maze-game-demo { { title "maze" } { pref-dim { 400 400 } } } main >>gadgets ;
