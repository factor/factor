
USING: accessors game.loop game_lib.board game_lib.loop game_lib.ui kernel math 
namespaces prettyprint sequences sokoban2.layouts ui ui.gadgets ;
IN: sokoban2.loop

TUPLE: game-state gadget ;

:: check-win ( board -- ? )
    board [ crate-cell cell-contains-instance? ] find-all-cells-nopos :> seq
    seq length 0 = not seq [ dark-crate make-crate cell-contains? ] all? and ;

:: <game-state> ( gadget -- gadget game-state )
    gadget 
    game-state new 
    gadget >>gadget ;

: create-loop ( game-state -- )
    10000000 swap new-game-loop start-loop ;

:: tick-update ( game-state -- )
    game-state gadget>> relayout-window
    game-state gadget>> board>> first check-win
    [
        game-state dup gadget>> { } >>board { } >>draw-quotes board-two >>gadget
        gadget>> { 2200 1100 } set-dim
        relayout-1

    ] when
    ;

M: game-state tick* tick-update ;

M: game-state draw* drop drop ;