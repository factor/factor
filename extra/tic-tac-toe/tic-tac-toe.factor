USING: kernel namespaces accessors math game_lib.ui game_lib.board colors.constants ui.gestures ui.gadgets ;

IN: tic-tac-toe

CONSTANT: X "vocab:tic-tac-toe/resources/X.png"
CONSTANT: O "vocab:tic-tac-toe/resources/O.png"

SYMBOL: player
X player set-global 

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

: set-player ( -- )
    player get-global X =
    [ O player set-global ]
    [ X player set-global ]
    if ;

:: set-board ( board cell-pos cell -- )
    board cell-pos is-cell-empty?
    [ 
        board cell-pos cell set-cell drop
        set-player
    ] when ;

:: on-click ( -- quot )
    [ dup dup board>> swap hand-rel-cell player get-global set-board relayout-1 ] ;

: game-logic ( gadget -- gadget )
    T{ button-down { # 1 } } on-click new-gesture 
    T{ button-down { # 3 } } on-click new-gesture ;

: main ( -- )
    { 400 400 } init-window
    background board foreground
    game-logic
    display ; 

MAIN: main