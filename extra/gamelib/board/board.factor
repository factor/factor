USING: assocs classes sequences sequences.generalizations math
timers sets kernel accessors sequences.extras ranges
math.vectors generalizations strings prettyprint gamelib.loop
ui.gadgets ;

IN: gamelib.board

TUPLE: board width height cells ;


CONSTANT: UP { 0 -1 } 
CONSTANT: DOWN { 0 1 } 
CONSTANT: RIGHT { 1 0 }
CONSTANT: LEFT { -1 0 }

! Make cells, with an empty sequence as the default cell
:: make-cells ( width height -- cells )
    height [ width [ { } clone ] replicate ] replicate ;

:: make-board ( width height -- board )
    width height make-cells :> cells
    width height cells board boa ;

! Sets all cells to an empty sequence
:: reset-board ( board -- board )
    board width>> board height>> make-board ;

:: get-cell ( board location -- cell )
    location first2 :> ( x y )
    board cells>> :> cells
    x y cells nth nth ;

! Gets all cells in locations array and return as a sequence
:: get-cells ( board locations -- seq )
    locations [ board swap get-cell ] map ;

:: get-instance-from-cell ( cell class -- object )
    cell [ class instance? ] find swap drop ;

! returns all elements of a specified row as a seq
:: get-row ( board index -- seq )
    index board cells>> nth ;

! returns all elements of a specified column as a seq
:: get-col ( board index -- seq )
    board 
    board height>> [ index ] replicate 
    board height>> [0..b) zip 
    get-cells ;

! For a board, set the cell at the given location to new-cell (should be a sequence)
:: set-cell ( board location new-cell -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    new-cell sequence? new-cell string? not and
    [
        new-cell x y cells nth set-nth
    ]
    [ "New cell is not a sequence! No changes made." . ] if
    board ;

! For a board, set all the given locations to a new cell (should be a sequence)
:: set-cells ( board locations new-cell -- board )
    locations [ board swap new-cell set-cell drop ] each
    board ;

! Applies a quotation to a specific cell
:: change-cell ( board location quot -- board )
    location first2 :> ( x y )
    board cells>> :> cells
    x y cells nth quot change-nth
    board ; inline

! Adds an object to the cell at the specified location in a board
:: add-to-cell ( board location obj -- board )
    board cells>> :> cells
    board location get-cell :> old-cell
    old-cell { obj } append :> new-cell
    board location new-cell set-cell ;

! Adds an object to all the given locations to new-cell 
:: add-to-cells ( board locations obj -- board )
    locations [ board swap obj add-to-cell drop ] each
    board ;

! Adds a copy of an object to all the given locations to new-cell
:: add-copy-to-cells ( board locations obj -- board )
    locations [ board swap obj clone add-to-cell drop ] each
    board ;

! Sets a cell back to the default cell
:: delete-cell ( board location -- board )
    board location { } set-cell ;

! Delete the first instance of obj in the cell at the specified location in the board (if found)
:: delete-from-cell ( board location obj -- board )
    board location get-cell :> cell
    cell [ obj = ] find drop :> obj-index
    obj-index
    [
        obj-index cell remove-nth :> new-cell
        board location new-cell set-cell
    ] [
        board
    ] if ;

! Delete the first instance of obj from all cells at the specified locations in the board (if found)
:: delete-from-cells ( board locations obj -- board )
    locations [ board swap obj delete-from-cell drop ] each
    board ;

! Like delete-from-cell, but delete all instances of obj (if found)
:: delete-all-from-cell ( board location obj -- board )
    board location [ obj swap remove ] change-cell ;

! Like delete-all-from-cell, but deletes from all specified locations in the board (if found)
:: delete-all-from-cells ( board locations obj -- board )
    locations [ board swap obj delete-all-from-cell drop ] each
    board ;

! Helper word that creates a sequence of n k's
:: make-n-k ( n k -- seq )
    n [ k ] replicate ;

! Helper word that creates a list of all cell locations in the board
:: location-matrix ( board -- loclist )
    board width>> :> w
    board height>> :> h
    w [0..b) :> single-row
    h [0..b) :> single-col
    h [ single-row ] replicate concat :> x-vals
    h [ w ] replicate :> w-list
    w-list single-col [ make-n-k ] 2map concat :> y-vals
    x-vals y-vals zip ;

! Sets all cells to a given sequence
:: set-all ( board seq -- board )
    board location-matrix :> loclist
    board loclist seq set-cells ;

! Deletes all instances of obj from all cells (if found)
:: delete-from-all ( board obj -- board )
    board location-matrix :> loclist
    board loclist obj delete-all-from-cells ;

:: duplicate-cell ( board start dest -- board )
    board dup start get-cell dest swap set-cell ;

! Moves an entire cell if it can be moved to a new destination, leaving the original cell empty
:: move-entire-cell ( board start dest -- board )
    ! bound checking
    { start dest } [ first board width>> < ] all? 
    { start dest } [ second board height>> < ] all? and
    start [ 0 >= ] all? and 
    dest [ 0 >= ] all? and 
    ! move cell
    [ board start dest duplicate-cell
    start delete-cell drop ] when 
    board ;

! Move an object from a cell, relative to its original cell
:: move-object ( board object-pos move object -- board )
    object-pos move v+ :> dest
    { object-pos dest } [ first board width>> < ] all? 
    { object-pos dest } [ second board height>> < ] all? and
    object-pos [ 0 >= ] all? and 
    dest [ 0 >= ] all? and 
    [ board object-pos object delete-from-cell
    dest object add-to-cell drop ] when
    board ;

! Move a specified object in many cells to different locations
:: move-objects ( board start dest object -- board )
    board start object delete-from-cells
    dest object add-to-cells ;

:: move-many-objects ( board start dest objects -- board )
    board objects [ start swap dest swap move-objects ] each ;

! move a cell with a move relative to its start
:: move-entire-cell-rel ( board start move -- board )
    board start start move v+ move-entire-cell ;

! move cells of a parent (only works when cells are all the same)
:: move-cells ( board start dest -- board )
    board start first get-cell :> cell
    board start [ delete-cell ] each
    dest cell set-cells ;

:: swap-cells ( board loc1 loc2 -- board )
    board loc1 get-cell :> cell1
    board loc2 get-cell :> cell2
    board loc2 cell1 set-cell
    loc1 cell2 set-cell ;

! Returns true if cell at location is the default cell
:: is-cell-empty? ( board location -- ? )
    board location get-cell { } = ;

:: is-board-empty? ( board -- ? )
    board cells>> [ [ { } = ] all? ] all? ;

! Return index and row that contains the first cell that satisfies the quot
:: find-row ( board quot -- index row )
    board cells>> [ [ quot find drop ] find drop ] find ; inline

! Return first location and cell that satisfies the quot
:: find-cell ( board quot -- seq cell )
    board quot find-row swap :> y
    [ quot find drop ] find swap :> x
    { x y } swap ; inline

! Return first cell that satisfies the quot
:: find-cell-nopos ( board quot -- cell )
    board cells>> [ quot find swap drop ] map-find drop ; inline

: find-cell-pos ( board quot -- seq )
    find-cell drop ; inline

! Returns a vector containing index row pairs
:: find-all-rows ( board quot -- index row )
    board cells>> [ quot find swap drop ] find-all ; inline

: is-empty? ( cell -- ? )
    { } = ;

: cell-contains? ( cell object -- ? )
    swap in? ;

:: cell-only-contains? ( cell object -- ? )
    cell length 1 = 
    cell object cell-contains? and ;

:: cell-contains-instance? ( cell class -- ? )
    cell [ class instance? ] any? ;

:: cell-only-contains-instance? ( cell class -- ? )
    cell length 1 = 
    cell class cell-contains-instance? and ;

! Helper function that formats a position cell pair
:: label-cell ( x cell y -- seq )
    { { x y } cell } ;

! Helper function that finds all cells in an given row that satisfy the quot 
:: row-to-cells ( seq quot -- cells )
    seq first2 :> ( y row )
    row quot find-all :> indexed-cells
    indexed-cells [ first2 y label-cell ] map ; inline

! Return a vector of position cell pairs of all cells in the board that satisfy the quot
:: find-all-cells ( board quot -- assoc )
    board quot find-all-rows :> row-list ! find-all - returns vector w/ index/elt
    row-list [ quot row-to-cells ] map concat ; inline

:: find-all-cells-nopos ( board quot -- assoc )
    board quot find-all-cells [ second ] map ; inline

:: all-equal-value? ( value seq -- ? )
    seq [ value = ] all? ;
