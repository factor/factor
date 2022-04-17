USING: assocs kernel classes prettyprint accessors sequences game_lib.board math.vectors ;
IN: game_lib.parent


TUPLE: parent children child ;

! :: move-children ( board parent move -- board )
!     parent children>> :> children
!     parent children [ move v+ ] map >>children drop
!     board children [ move move-entire-cell-rel ] each ;

:: move-children ( board parent move -- board )
    parent children>> :> children
    parent children [ move v+ ] map >>children drop
    board children children [ move v+ ] map move-cells ;

:: make-parent ( children child -- parent )
    children child parent boa ;

:: fill-board-parent ( board parent -- board )
    board parent children>> { parent f } set-cells ;

: main ( -- )
    3 3 make-board
    { { 0 0 } { 1 0 } } f make-parent fill-board-parent dup .
    dup { 0 0 } get-cell first { 1 0 } move-children .
    ;

MAIN: main