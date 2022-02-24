USING: game_lib.ui game_lib.board ;

IN: sokoban2

CONSTANT: player "vocab:sokoban2/resources/CharR.png"
CONSTANT: wall "vocab:sokoban2/resources/Wall_Brown.png"
CONSTANT: goal "vocab:sokoban2/resources/Goal.png"
CONSTANT: crate "vocab:sokoban2/resources/Crate_Yellow.png"

! TODO: reverse x y values when board is updated
: board ( gadget -- gadget )
    8 9 f make-board
    
    { 2 2 } player set-cell

    {
                        { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 }
        { 0 2 }                                         { 6 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 }
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 }                                                 { 7 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 }
    } wall set-multicell
    
    {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
    } goal set-multicell

    { 
        { 3 2 } { 4 3 } { 4 4 } { 4 6 } { 3 6 } { 5 6 }
    } crate set-multicell

    create-board ;


: main ( -- )
    { 700 800 } init-window
    board
    display ;

MAIN: main