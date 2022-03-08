USING: assocs sequences sequences.generalizations kernel accessors sequences.extras math.ranges ;

IN: game_lib.board

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

! Gets all cells in locations array and return as a sequence
:: get-multicell ( board locations -- seq )
    locations [ board swap get-cell ] map ;

! returns all elements of a specified row as a seq
:: get-row ( board index -- seq )
    index board cells>> nth ;

! returns all elements of a specified column as a seq
:: get-col ( board index -- seq )
    board 
    board height>> [ index ] replicate 
    board height>> [0..b) zip 
    get-multicell ;

! For a board, set the cell at the given location to new-cell
:: set-cell ( board location new-cell -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    new-cell x y cells nth set-nth
    board ;

! For a board, set all the given locations to new-cell
:: set-multicell ( board locations new-cell -- board )
    locations [ board swap new-cell set-cell drop ] each
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

! Returns true if cell at location is the default cell
:: is-cell-empty? ( board location -- ? )
    board location get-cell board default-cell>> = ;

:: is-board-empty? ( board -- ? )
    board cells>> [ [ board default-cell>> = ] all? ] all? ;

! Applies a quotation to a specific cell
:: change-cell ( board location quot -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    y x cells nth quot change-nth
    board ; inline

! Return index and row that contains the first cell that satisfies the quot
:: find-row ( board quot -- index row )
    board cells>> [ quot find drop ] find ; inline

! Return first location and cell that satisfies the quot
:: find-cell ( board quot -- seq cell )
    board quot find-row swap :> y
    quot find swap :> x
    { x y } swap ; inline

! Return first cell that satisfies the quot
:: find-cell-nopos ( board quot -- cell )
    board cells>> [ quot find swap drop ] map-find drop ; inline

: find-cell-pos ( board quot -- seq )
    find-cell drop ; inline

! Returns a vector containing index row pairs
:: find-all-rows ( board quot -- index row )
    board cells>> [ quot find swap drop not not ] find-all ; inline


! Helper function that formats a position cell pair
:: label-cell ( y cell x -- seq )
    { { x y } cell } ;

! Helper function that finds all cells in an given row that satisfy the quot 
:: row-to-cells ( seq quot -- cells )
    seq first2 :> ( x row )
    row quot find-all :> indexed-cells
    indexed-cells [ first2 x label-cell ] map ; inline

! Return a vector of position cell pairs of all cells in the board that satisfy the quot
:: find-all-cells ( board quot -- assoc )
    board quot find-all-rows :> row-list ! find-all - returns vector w/ index/elt
    row-list [ quot row-to-cells ] map concat ; inline

:: all-equal-value? ( value seq -- ? )
    seq [ value = ] all? ;