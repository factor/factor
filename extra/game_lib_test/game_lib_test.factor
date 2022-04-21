USING: accessors colors game_lib.board game_lib.ui kernel math
math.vectors sequences ui ui.gadgets ui.gadgets.scrollers
ui.gadgets.sliders ui.gadgets.status-bar ui.gadgets.tracks
ui.gestures ;
IN: game_lib_test

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

! :: bound-check ( new-pos -- ? )
!     new-pos [ 0 >= ] all? 
!     new-pos [ 17 < ] all? and ;

! :: move ( board move -- ) 
!     board [ COLOR: blue = ] find-cell-pos :> player-pos
!     player-pos move v+ :> new-pos
!     new-pos bound-check
!     [
!         board new-pos get-cell :> adjacent-cell
!         adjacent-cell is-empty?
!         [ board player-pos new-pos move-entire-cell drop ] when 
!     ] when ; 

: logic ( gadget -- gadget )
    T{ key-down f f "UP" } [ dup board>> first UP move relayout ] new-gesture
    T{ key-down f f "DOWN" } [ dup board>> first DOWN move relayout ] new-gesture
    T{ key-down f f "LEFT" } [ dup board>> first LEFT move relayout ] new-gesture
    T{ key-down f f "RIGHT" } [ dup board>> first RIGHT move relayout ] new-gesture 
    T{ key-down f f "n" } [ { } >>board board relayout ] new-gesture ;


! : main ( -- gadget )
!     { 1600 1600 } init-board-gadget 
!     board 
!     logic 
!     <scroller> { } 1sequence vertical 0 1 <window> ;

TUPLE: maze-gadget < track scroller ;

maze-gadget H{
    { T{ key-down f f "RIGHT" } [ scroller>> x>> 40 swap slide-by ] } 
    { T{ key-down f f "LEFT" } [ scroller>> x>> -40 swap slide-by ] } 
    { T{ key-down f f "UP" } [ scroller>> y>> -40 swap slide-by ] } 
    { T{ key-down f f "DOWN" } [ scroller>> y>> 40 swap slide-by ] } 
} set-gestures

: main ( -- )
    vertical maze-gadget new-track
    { 2000 2000 } init-board-gadget
    board
    ! logic
    <scroller> [ >>scroller ] keep
    1 track-add
    display ;

MAIN: main 
! MAIN-WINDOW: maze-game-demo { { title "maze" } { pref-dim { 400 400 } } } main >>gadgets ;