
USING: literals kernel namespaces accessors sequences
combinators math.vectors colors gamelib.ui gamelib.board
gamelib.cell-object gamelib.loop game.loop ui.gestures
ui.gadgets opengl opengl.textures images.loader prettyprint
strings classes ;

IN: gamelib.demos.parent-demo

CONSTANT: player "vocab:gamelib/demos/parent-demo/resources/CharR.png"
CONSTANT: wall "vocab:gamelib/demos/parent-demo/resources/Wall_Brown.png"
CONSTANT: goal "vocab:gamelib/demos/parent-demo/resources/Goal.png"
CONSTANT: light-crate "vocab:gamelib/demos/parent-demo/resources/Crate_Yellow.png"
CONSTANT: dark-crate "vocab:gamelib/demos/parent-demo/resources/CrateDark_Yellow.png"

TUPLE: crate-cell < child-cell image-path ;
M: crate-cell draw-cell-object* 
    rot [ image-path>> load-image ] dip <texture> draw-scaled-texture ;

M: crate-cell call-parent*
    parent>> dup function>> call( board move parent -- board ) drop ; inline

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
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 } { 7 0 }
        { 0 1 }                                                 { 7 1 }
        { 0 2 }                                                 { 7 2 }
        { 0 3 }                                                 { 7 3 }
        { 0 4 }                                                 { 7 4 }
        { 0 5 }                                                 { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 }                                                 { 7 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 }

    } $ wall add-to-cells
    
    { 

        { 3 4 } { 4 4 } { 5 4 } { 4 3 }
    } dup parent swap >>children drop light-crate parent make-crate add-copy-to-cells ;

: board-one ( gadget parent -- gadget )
    board-one-bg { } 1sequence add-board ;

:: get-pos ( board object -- seq )
    board [ object = ] find-cell-pos ;

:: move-crate ( board player-pos move crate -- )
    player-pos move v+ :> crate-pos
    board crate-pos move v+ get-cell :> next-cell
    ! Move both the player and crate if possible, otherwise do nothing
    {
        { 
            [ next-cell class-of wall class-of = not ] ! crate can be moved to free space
            [ crate light-crate >>image-path drop 
            ! board crate parent>> move move-children
            board move crate call-parent*
            board player-pos move player move-object drop ] 
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

: game-logic ( gadget -- gadget )
    ! Move pieces according to user input
    T{ key-down f f "UP" } [ board>> first UP sokoban-move ] new-gesture
    T{ key-down f f "DOWN" } [ board>> first DOWN sokoban-move ] new-gesture
    T{ key-down f f "RIGHT" } [ board>> first RIGHT sokoban-move ] new-gesture
    T{ key-down f f "LEFT" } [ board>> first LEFT sokoban-move ] new-gesture ;

TUPLE: game-state gadget ;

:: <game-state> ( gadget -- gadget game-state )
    gadget 
    game-state new 
    gadget >>gadget ;

: create-loop ( game-state -- )
    10000000 swap new-game-loop start-loop ;

:: tick-update ( game-state -- )
    game-state gadget>> relayout ;

M: game-state tick* tick-update ;

M: game-state draw* drop drop ;


: main ( -- )
    { 700 800 } init-board-gadget
    <crate-parent>
    board-one
    <game-state> create-loop
    game-logic
    display ;

MAIN: main
