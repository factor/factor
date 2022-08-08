
USING: accessors colors fonts game.loop gamelib.board
gamelib.loop gamelib.ui kernel math namespaces opengl
prettyprint sequences gamelib.demos.sokoban.layouts ui ui.gadgets ui.text
combinators ;

IN: gamelib.demos.sokoban.loop

SYMBOL: level

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

: game-over ( gadget -- gadget )
    [ { 200 200 } [ monospace-font t >>bold? 50 >>size COLOR: red >>foreground "YOU WIN!" draw-text ] with-translation ] draw-quote ;

:: tick-update ( game-state -- )
    game-state gadget>> :> g
    g relayout-window
    g board>> first check-win
    [ 
        {
            { [ level get-global 0 = ] [ level [ 1 + ] change-global game-state g { } >>board { } >>draw-quotes board-two >>gadget drop g { 1500 750 } set-dim relayout ] }
            { [ level get-global 1 = ] [ level [ 1 + ] change-global game-state g { } >>board { } >>draw-quotes board-three >>gadget drop g { 600 600 } set-dim relayout ] }
            { [ level get-global 2 = ] [ g game-over relayout-1 stop-game ] }
        } cond
    ] when ;

M: game-state tick* tick-update ;

M: game-state draw* drop drop ;
