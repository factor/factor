USING: sequences kernel accessors ;

IN: gamedev.board

TUPLE: board width height cells ;

:: make-cells ( cell width height -- cells )
    height [ width [ cell ] replicate ] replicate ;

:: make-board ( cells -- board )
    cells length :> height
    cells first length :> width
    width height cells board boa ;

:: get-cell ( board location -- cell )
    location first :> x
    location second :> y
    board cells>> :> cells
    x y cells nth nth ;

:: set-cell ( board location new-cell -- )
    location first :> x
    location second :> y
    board cells>> :> cells
    new-cell x y cells nth set-nth ;

:: modify-cell ( board location quot -- )
    location first :> x
    location second :> y
    board cells>> :> cells
    x y cells nth quot change-nth ;