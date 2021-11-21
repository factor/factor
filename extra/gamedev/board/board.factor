USING: sequences kernel accessors ;

IN: gamedev.board

TUPLE: board width height cells default-cell ;

! use clone so the cells don't all point to the same location in memory

:: make-cells ( cell width height -- cells )
    height [ width [ cell clone ] replicate ] replicate ;

:: make-board ( width height default-cell -- board )
    default-cell width height make-cells :> cells
    width height cells default-cell board boa ;

:: get-cell ( board location -- cell )
    location first2 :> ( x y )
    board cells>> :> cells
    x y cells nth nth ;

:: set-cell ( board new-cell location -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    new-cell x y cells nth set-nth
    board ;

:: delete-cell ( board location -- board )
    board dup default-cell>> location set-cell ;

:: duplicate-cell ( board start dest -- board )
    board dup start get-cell dest set-cell ;

:: move-cell ( board start dest -- board )
    board start dest duplicate-cell
    start delete-cell ;

:: swap-cells ( board loc1 loc2 -- board )
    board loc1 get-cell :> cell1
    board loc2 get-cell :> cell2
    board cell1 loc2 set-cell
    cell2 loc1 set-cell ;

:: is-empty? ( board location -- ? )
    board location get-cell board default-cell>> = ;

:: change-cell ( board location quot -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    y x cells nth quot change-nth
    board ; inline

! :: reset-board ( board )

! implement parent-piece