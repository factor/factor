USING: sequences kernel accessors ;

IN: gamedev.board

TUPLE: board width height cells ;

:: make-cells ( width height cell -- cells )
    height [ width [ cell ] replicate ] replicate ;

:: make-board ( cells -- board )
    cells length :> height
    cells first length :> width
    width height cells board boa ;

:: get-cell ( location board -- cell )
    location first :> x
    location second :> y
    board cells>> :> cells
    x y cells nth nth ;