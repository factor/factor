USING: literals kernel namespaces accessors sequences
combinators math.vectors colors gamelib.ui gamelib.board
gamelib.cell-object gamelib.loop game.loop ui.gestures
ui.gadgets opengl opengl.textures images.loader prettyprint
layouts gamelib.demos.sokoban.layouts gamelib.demos.sokoban.loop ;

IN: gamelib.demos.sokoban

CONSTANT: player "vocab:gamelib/demos/sokoban/resources/CharR.png"
CONSTANT: wall "vocab:gamelib/demos/sokoban/resources/Wall_Brown.png"
CONSTANT: goal "vocab:gamelib/demos/sokoban/resources/Goal.png"
CONSTANT: light-crate "vocab:gamelib/demos/sokoban/resources/Crate_Yellow.png"
CONSTANT: dark-crate "vocab:gamelib/demos/sokoban/resources/CrateDark_Yellow.png"

:: move-crate ( board player-pos move crate -- )
    player-pos move v+ :> crate-pos
    board crate-pos move v+ get-cell :> next-cell
    ! Move both the player and crate if possible, otherwise do nothing
    {
        { 
            [ next-cell is-empty? ] ! crate can be moved to free space
            [ crate light-crate >>image-path drop 
            board crate-pos move crate move-object 
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
    board [ player = ] find-cell-pos :> player-pos
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

: main ( -- )
    [ 0 level set-global ] with-global ! set global level variable to 0
    { 600 675 } init-board-gadget
    board-one
    <game-state> create-loop
    game-logic
    display ;

MAIN: main
