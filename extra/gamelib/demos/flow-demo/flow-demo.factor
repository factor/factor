
USING: literals kernel namespaces accessors sequences
combinators math.vectors colors gamelib.ui gamelib.board
gamelib.cell-object gamelib.loop game.loop ui.gestures
ui.gadgets opengl opengl.textures images.loader prettyprint
classes math ;

IN: gamelib.demos.flow-demo

CONSTANT: light-crate "vocab:gamelib/demos/sokoban/resources/Crate_Yellow.png"

TUPLE: crate-cell < flowcell-object image-path ;

! Note -- probably need to cache larger images
M: crate-cell draw-cell-object* 
    rot [ image-path>> load-image ] dip <texture> draw-scaled-texture ;

:: make-crate ( image-path -- crate )
    crate-cell new 
    f image-path crate-cell boa ;

: board-one ( gadget -- gadget )
    8 9 make-board

    { { 1 1 } } light-crate make-crate RIGHT 220 set-flow add-to-cells 
    { { 3 1 } } light-crate make-crate DOWN 75 set-flow add-to-cells
    { { 5 1 } } light-crate make-crate DOWN 20 set-flow add-to-cells 
    { } 1sequence add-board ;

! -------------------- Game loop --------------------------------------------------
    
TUPLE: game-state gadget ;

:: <game-state> ( gadget -- gadget game-state )
    gadget 
    game-state new 
    gadget >>gadget ;

: create-loop ( game-state -- )
    10000000 swap new-game-loop start-loop ;

! Updates a crate-cell's location if a target number of frames have passed, otherwise it updates the counter
:: update-location ( board loc flowcell-object -- )
    flowcell-object flow-on?
    [
        flowcell-object flow>> :> flow-obj
        flow-obj target>> :> target
        flow-obj counter>> 1 + :> counter
        counter target =
        [
            flow-obj direction>> :> direction
            board loc direction flowcell-object move-object drop
            flow-obj 0 >>counter drop

        ]
        [
            flow-obj counter >>counter drop
        ]
        if
        flowcell-object flow-obj >>flow drop
    ] when ;

! Takes in a cell object and updates its location based on its flow if the cell object is a crate-cell
:: update-all-flowcells ( board loc obj -- )
    obj crate-cell instance?
    [
        board loc obj update-location
    ] when ;

! Takes a board, a location, and the corresponding cell and updates all crate-cell objects in the cell
:: update-all-cells-with-flowcells ( board pair -- )
    pair first2 :> ( loc cell )
    board loc cell [ update-all-flowcells ] 2with each ;

:: tick-update ( game-state -- )
    game-state gadget>> :> g
    g board>> :> boards
    boards first [ crate-cell cell-contains-instance? ] find-all-cells :> all-cells
    boards first all-cells [ update-all-cells-with-flowcells ] with each
    g relayout ;

M: game-state tick* tick-update ;

M: game-state draw* drop drop ;


: main ( -- )
    { 700 800 } init-board-gadget
    board-one
    <game-state> create-loop
    display ;

MAIN: main
