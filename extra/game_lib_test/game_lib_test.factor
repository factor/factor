USING: accessors sequences kernel grouping game_lib.ui colors.constants ui.gadgets game_lib.board ui.gestures words assocs ;

IN: game_lib_test

! The user must call init-window with a dimension sequence first, 
! followed by optional draw/board functions, 
! and must call display last to see the window with everything drawn

! trying to have the action be nothing if somethign is already in cell 
! :: set-action-x ( gadget -- value )
!     ! gadget gesture-pos :> curCell
!     gadget board>> curCell get-cell
!     ! f
!     [ 
!         [ gadget board>> gadget gesture-pos "vocab:game_lib_test/resources/X.png" set-cell drop relayout-1 ]
!     ] [ 
!         [ drop ]
!     ] if ;

CONSTANT: X "vocab:game_lib_test/resources/X.png"
CONSTANT: O "vocab:game_lib_test/resources/O.png"

TUPLE: game-state p1 ;

:: set-action-x ( gadget -- value ) 
    [ gadget board>> gadget gesture-pos "vocab:game_lib_test/resources/X.png" set-cell drop relayout-1 ] ;

:: set-action-o ( gadget -- value ) 
    [ gadget board>> gadget gesture-pos "vocab:game_lib_test/resources/O.png" set-cell drop relayout-1 ] ;

:: on-click ( gadget -- value )
    [ 
        gadget rules>>
        [ gadget board>> gadget gesture-pos X set-cell drop relayout-1 gadget f >>rules drop ]
        [ gadget board>> gadget gesture-pos O set-cell drop relayout-1 gadget t >>rules drop ]
        if
    ] ;

! TODO: incorporate this check for every loop once game loop is ready
:: row-win ( board -- ? )
    ! second approach in col-win -- which is better, or is there another better approach?
    board 0 get-row all-equal? 
    board 1 get-row all-equal? 
    or 
    board 2 get-row all-equal? 
    or ;

:: col-win ( board -- ? )
    { 0 1 2 } [ board swap get-col ] map 
    [ all-equal? ] any? ;

:: diag-win ( board -- ? )
    board { { 0 0 } { 1 1 } { 2 2 } } get-multicell all-equal?
    board { { 2 0 } { 1 1 } { 0 2 } } get-multicell all-equal?
    or ;

:: check-win ( board -- ? )
    board is-board-empty?
    [
        ! Empty board -- no winners yet 
        f
    ] [
        board row-win board col-win or
        board diag-win or 
    ] if ;


: gestures ( gadget -- gadget )
    ! TODO: generalize action quote and make easier to use
    ! dup set-action-x T{ button-down { # 1 } } new-gestures 
    ! dup set-action-o T{ button-down { # 3 } } new-gestures 
    dup on-click T{ button-down { # 1 } } new-gestures
    make-gestures ;

: draw ( gadget -- gadget )
    COLOR: pink set-background-color
    COLOR: green { 0 0 } { 150 150 } draw-filled-rectangle ! draws this first
    COLOR: blue { 0 0 } { 100 100 } draw-filled-rectangle ;

: board ( gadget -- gadget )
    ! sprites takes up the entire screen and can only draw sprites as of now    
    3 3 f make-board 
    ! { 2 0 } "vocab:game_lib_test/resources/O.png" set-cell
    ! { 1 1 } "vocab:game_lib_test/resources/O.png" set-cell
    ! { 2 2 } "vocab:game_lib_test/resources/X.png" set-cell
    create-board ;

: <game-state> ( gadget -- gadget )
    game-state new
    f >>p1
    set-rules ;

: display-window ( -- )
    { 400 200 } init-window ! initialize the window with dimensions
    draw ! optional function to draw rectangles or sprites
    board ! optional function to create a board

    ! <game-state> 
    gestures ! sets gestures -- a hashmap of key presses and associated actions



    display ; ! call display to see the window

    ! note: using relayout seems to change the window correctly

MAIN: display-window