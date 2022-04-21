
USING: literals kernel namespaces accessors sequences combinators math.vectors colors
game_lib.ui game_lib.board game_lib.cell game_lib.loop game.loop ui.gestures ui.gadgets opengl opengl.textures
images.loader prettyprint game_lib.parent ;

IN: parent-demo

CONSTANT: player "vocab:parent-demo/resources/CharR.png"
CONSTANT: wall "vocab:parent-demo/resources/Wall_Brown.png"
CONSTANT: goal "vocab:parent-demo/resources/Goal.png"
CONSTANT: light-crate "vocab:parent-demo/resources/Crate_Yellow.png"
CONSTANT: dark-crate "vocab:parent-demo/resources/CrateDark_Yellow.png"

TUPLE: crate-cell < child-cell image-path ;
M: crate-cell draw-cell* 
    rot [ image-path>> load-image ] dip <texture> draw-scaled-texture ;

M: crate-cell call-parent*
    drop drop ;

SYMBOL: level 
0 level set-global

: <crate-parent> ( -- parent )
    { } [ move-children ] <parent> ;

:: make-crate ( image-path parent -- crate )
    crate-cell new
    parent image-path crate-cell boa ;

:: board-one-bg ( parent -- board )
    8 9 make-board
    
    { 2 2 } player add-to-cell

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

    } $ wall add-to-cells


    {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
    } $ goal add-to-cells
    
    { 

        { 1 6 } { 3 2 } { 4 3 } { 4 4 } { 4 6 } { 3 6 } { 5 6 }
    } dup parent swap >>children drop light-crate parent make-crate add-copy-to-cells ;

: board-one-fg ( -- board )
    ! just to showcase stackable boards
    8 9 make-board

    { { 5 2 } { 5 1 } } COLOR: blue add-to-cells ;

: board-one ( gadget parent -- gadget )
    board-one-bg board-one-fg { } 2sequence create-board ;

: board-two ( gadget -- gadget )
    22 11 make-board
    
    { 11 8 } player add-to-cell

    {
                                        { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
                                        { 4 1 }                         { 8 1 }
                                        { 4 2 }                         { 8 2 }
                        { 2 3 } { 3 3 } { 4 3 }                         { 8 3 } { 9 3 } { 10 3 }
                        { 2 4 }                                                         { 10 4 }
        { 0 5 } { 1 5 } { 2 5 }         { 4 5 }         { 6 5 } { 7 5 } { 8 5 }         { 10 5 }                                              { 16 5 } { 17 5 } { 18 5 } { 19 5 } { 20 5 } { 21 5 }
        { 0 6 }                         { 4 6 }         { 6 6 } { 7 6 } { 8 6 }         { 10 6 } { 11 6 } { 12 6 } { 13 6 } { 14 6 } { 15 6 } { 16 6 }                                     { 21 6 }
        { 0 7 }                                                                                                                                                                            { 21 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 }         { 6 8 } { 7 8 } { 8 8 }         { 10 8 }          { 12 8 } { 13 8 } { 14 8 } { 15 8 } { 16 8 }                                     { 21 8 }
                                        { 4 9 }                                         { 10 9 } { 11 9 } { 12 9 }                            { 16 9 } { 17 9 } { 18 9 } { 19 9 } { 20 9 } { 21 9 }
                                        { 4 10 } { 5 10 } { 6 10 } { 7 10 } { 8 10 } { 9 10 } { 10 10 }  
    } wall add-to-cells
    
    {
        { 19 6 } { 20 6 }
        { 19 7 } { 20 7 }
        { 19 8 } { 20 8 }
    } goal add-to-cells

    { 
        { 5 2 } { 7 3 } { 5 4 } { 8 4 } { 5 7 } { 2 7 }
    } light-crate add-to-cells

    { } 1sequence 

    create-board ;

: board ( -- seq )
    { [ board-one ] [ board-two ] } ;

:: get-pos ( board object -- seq )
    board [ object = ] find-cell-pos ;

:: move-crate ( board player-pos move crate -- )
    player-pos move v+ :> crate-pos
    board crate-pos move v+ get-cell :> next-cell
    ! Move both the player and crate if possible, otherwise do nothing
    {
        { 
            [ next-cell is-empty? ] ! crate can be moved to free space
            [ crate light-crate >>image-path drop 
            board crate parent>> move move-children
            player-pos move player move-object drop ] 
        }
        { 
            [ next-cell goal cell-only-contains? ] ! crate can be moved to goal
            [ crate dark-crate >>image-path drop 
            board crate-pos move crate move-object 
            player-pos move player move-object drop ] 
        }
        [ ] ! Else do nothing
    } cond ;

:: sokoban-move ( board move -- )
    board player get-pos :> player-pos
    player-pos move v+ :> new-pos
    board new-pos get-cell :> adjacent-cell
    ! Move player to free space or have player push crate if possible, otherwise do nothing
    {
        { 
            [ adjacent-cell crate-cell cell-contains-instance? ] ! player is moving into a crate
            [ adjacent-cell crate-cell get-instance-from-cell :> crate
            board player-pos move crate move-crate ]
        }
        {
            [ adjacent-cell is-empty? adjacent-cell goal cell-contains? or ] ! player can be moved to free space or goal
            [ board player-pos move player move-object drop ] 
        }
        [ ] ! Else do nothing
    } cond ;

:: check-win ( board -- ? )
    board [ crate-cell cell-contains-instance? ] find-all-cells-nopos :> seq
    seq length 0 = not seq [ dark-crate f make-crate cell-contains? ] all? and ;

: game-logic ( gadget -- gadget )
    ! Move pieces according to user input
    T{ key-down f f "UP" } [ board>> first UP sokoban-move ] new-gesture
    T{ key-down f f "DOWN" } [ board>> first DOWN sokoban-move ] new-gesture
    T{ key-down f f "RIGHT" } [ board>> first RIGHT sokoban-move ] new-gesture
    T{ key-down f f "LEFT" } [ board>> first LEFT sokoban-move ] new-gesture ;
    ! T{ key-down f f "n" } [ dup board>> first reset-board { 700 800 } init-window level get-global board nth call( gadget -- gadget ) ] new-gesture ;

TUPLE: game-state gadget ;

:: <game-state> ( gadget -- gadget game-state )
    gadget 
    game-state new 
    gadget >>gadget ;

: create-loop ( game-state -- )
    10000000 swap new-game-loop start-loop ;

! : tick-update ( game-state -- )
!     gadget>> relayout ;

:: tick-update ( game-state -- )
    game-state gadget>> relayout
    game-state gadget>> board>> first check-win
    [ "pass" . ] when ;

M: game-state tick* tick-update ;

M: game-state draw* drop drop ;


: main ( -- )
    { 700 800 } init-window
    ! Don't really like this sequence of quotes thing -- would be nicer if board 
    ! could be an array of like ascii that gets created here or something
    ! level get-global board nth call( gadget -- gadget )
    <crate-parent>
    board-one
    <game-state> create-loop
    game-logic
    display ;

MAIN: main