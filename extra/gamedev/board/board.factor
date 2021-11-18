USING: sequences kernel accessors ;

IN: gamedev.board

TUPLE: board width height cells default-cell ;

:: make-cells ( cell width height -- cells )
    height [ width [ cell ] replicate ] replicate ;

:: make-board ( cells default-cell -- board )
    cells length :> height
    cells first length :> width
    width height default-cell cells board boa ;

:: get-cell ( board location -- cell )
    location first :> x
    location second :> y
    board cells>> :> cells
    x y cells nth nth ;

:: set-cell ( new-cell board location -- board )
    location first :> x
    location second :> y
    board cells>> :> cells
    new-cell x y cells nth set-nth
    board ;

:: delete-cell ( board location -- board )
    board default-cell>> board location set-cell ;

:: duplicate-cell ( board start dest -- board )
    board start get-cell board dest set-cell ;