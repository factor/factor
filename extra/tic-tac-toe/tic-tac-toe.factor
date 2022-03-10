USING: math game_lib.ui game_lib.board colors.constants ;

IN: tic-tac-toe

CONSTANT: X "vocab:tic-tac-toe/resources/X.png"
CONSTANT: O "vocab:tic-tac-toe/resources/O.png"

: background ( gadget -- gadget )
    COLOR: pink set-background-color ;

: foreground ( gadget -- gadget ) 
    COLOR: black { 123 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 256 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 0 123 } { 400 10 } draw-filled-rectangle
    COLOR: black { 0 256 } { 400 10 } draw-filled-rectangle ;

: board ( gadget -- gadget )
    ! sprites takes up the entire screen and can only draw sprites as of now    
    3 3 f make-board
    create-board ; 

: main ( -- )
    { 400 400 } init-window
    background board foreground
    display ; 

MAIN: main