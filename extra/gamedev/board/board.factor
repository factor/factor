USING: sequences kernel accessors ;

IN: gamedev.board

TUPLE: board width height cells default-cell ;

:: make-cells ( width height cell -- cells )
    height [ width [ cell clone ] replicate ] replicate ;

:: make-board ( width height default-cell -- board )
    width height default-cell make-cells :> cells
    width height cells default-cell board boa ;

! Sets all cells to the default cell
:: reset-board ( board -- board )
    board width>> board height>> board default-cell>> make-board ;

:: get-cell ( board location -- cell )
    location first2 :> ( x y )
    board cells>> :> cells
    x y cells nth nth ;

:: set-cell ( board location new-cell -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    new-cell x y cells nth set-nth
    board ;

! Sets a cell back to the default cell
:: delete-cell ( board location -- board )
    board location board default-cell>> set-cell ;

:: duplicate-cell ( board start dest -- board )
    board dup start get-cell dest set-cell ;

:: move-cell ( board start dest -- board )
    board start dest duplicate-cell
    start delete-cell ;

:: swap-cells ( board loc1 loc2 -- board )
    board loc1 get-cell :> cell1
    board loc2 get-cell :> cell2
    board loc2 cell1 set-cell
    loc1 cell2 set-cell ;

! Returns true if all cells are the default cell
:: is-empty? ( board location -- ? )
    board location get-cell board default-cell>> = ;

! Applies a quotation to a specific cell
:: change-cell ( board location quot -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    y x cells nth quot change-nth
    board ; inline

! Return index and row that contains the first cell that satisfies quot
:: find-row ( board quot -- index row )
    board cells>> [ quot find swap drop not not ] find ; inline

! Return location and cell that satisfies quot
:: find-cell ( board quot -- x y cell )
    board quot find-row swap :> y
    quot find swap :> x
    { x y } swap ; inline

! implement parent-piece