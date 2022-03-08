USING: game_lib.ui game_lib.board colors.constants ;

IN: tic-tac-toe

CONSTANT: X "vocab:tic-tac-toe/resources/X.png"
CONSTANT: O "vocab:tic-tac-toe/resources/O.png"

: draw ( gadget -- gadget )
    COLOR: pink set-background-color ;

: board ( gadget -- gadget )
    ! sprites takes up the entire screen and can only draw sprites as of now    
    3 3 f make-board
    { 1 0 } O set-cell
    { 2 0 } X set-cell
    create-board ; 

: main ( -- )
    { 400 400 } init-window
    draw
    board 
    display ; 

MAIN: main