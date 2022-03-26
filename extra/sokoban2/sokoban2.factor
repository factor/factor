USING: literals kernel namespaces accessors sequences combinators math.vectors colors.constants 
game_lib.ui game_lib.board game_lib.cell ui.gestures ui.gadgets opengl opengl.textures
images.loader ;

IN: sokoban2

CONSTANT: player "vocab:sokoban2/resources/CharR.png"
CONSTANT: wall "vocab:sokoban2/resources/Wall_Brown.png"
CONSTANT: goal "vocab:sokoban2/resources/Goal.png"
CONSTANT: crate "vocab:sokoban2/resources/Crate_Yellow.png"
CONSTANT: dark_crate "vocab:sokoban2/resources/CrateDark_Yellow.png"

TUPLE: sokoban-cell < cell image-path cell-name ;
M: sokoban-cell draw-cell* 
    rot [ image-path>> load-image ] dip <texture> draw-scaled-texture ;

SYMBOL: level 
0 level set-global

: board-one ( gadget -- gadget )
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
        { 1 6 } { 3 2 } { 4 3 } { 4 4 } { 4 6 } { 3 6 } { 5 6 }
    } $ crate add-to-cells

    {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
    } $ goal add-to-cells

    ! { 1 2 } { "vocab:sokoban2/resources/Crate_Yellow.png" "vocab:sokoban2/resources/Goal.png" } set-cell
    { 0 0 } [ COLOR: black gl-color { 10 10 } { 20 20 } gl-fill-rect ] set-cell ;
    
: board-second ( -- board )
    8 9 f make-board

    {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
    } goal set-multicell ;

: board-one ( gadget -- gadget )
    board-first board-second { } 2sequence create-board ;

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
    } crate add-to-cells

    { } 1sequence 

    create-board ;

: board ( -- seq )
    { [ board-one ] [ board-two ] } ;

:: get-pos ( board object -- seq )
    board [ object = ] find-cell-pos ;

:: move-crate ( board player-pos move -- )
    player-pos move v+ :> crate-pos
    board crate-pos move v+ get-cell :> next-cell
    ! Move both the player and crate if possible, otherwise do nothing
    {
        { 
            [ next-cell is-empty? next-cell goal cell-only-contains? or ] ! crate can be moved to free space FIX THIS BOIIII
            [ board crate-pos move crate move-object 
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
            [ adjacent-cell crate cell-contains? ] ! player is moving into a crate
            [ board player-pos move move-crate ] 
        }
        {
            [ adjacent-cell is-empty? adjacent-cell goal cell-contains? or ] ! player can be moved to free space
            [ board player-pos move player move-object drop ] 
        }
        ! {
        !     [ adjacent-cell goal = ] ! player is moving into a goal
        !     [ ]
        !     ! [ board move { "vocab:sokoban2/resources/CharR.png" "vocab:sokoban2/resources/Goal.png" } player-pos move-object ]
        ! }
        [ ] ! Else do nothing
    } cond ;

: game-logic ( gadget -- gadget )
    ! Move pieces according to user input
    T{ key-down f f "UP" } [ dup board>> { 0 -1 } sokoban-move relayout-1 ] new-gesture
    T{ key-down f f "DOWN" } [ dup board>> { 0 1 } sokoban-move relayout-1 ] new-gesture
    T{ key-down f f "RIGHT" } [ dup board>> { 1 0 } sokoban-move relayout-1 ] new-gesture
    T{ key-down f f "LEFT" } [ dup board>> { -1 0 } sokoban-move relayout-1 ] new-gesture ;

: main ( -- )
    { 700 800 } init-window
    ! Don't really like this sequence of quotes thing -- would be nicer if board 
    ! could be an array of like ascii that gets created here or something
    level get-global board nth call( gadget -- gadget )
    ! board
    game-logic
    display ;

MAIN: main