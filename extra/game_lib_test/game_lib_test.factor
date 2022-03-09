USING: accessors sequences kernel grouping game_lib.ui colors.constants ui.gadgets game_lib.board ui.gestures words assocs game.loop delegate namespaces ;

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

TUPLE: game-state gadget p1 ;


SYMBOL: tictactoe-game-loop

! :: set-action-x ( gadget -- value ) 
!     [ gadget board>> gadget gesture-pos "vocab:game_lib_test/resources/X.png" set-cell drop relayout-1 ] ;

! :: set-action-o ( gadget -- value ) 
!     [ gadget board>> gadget gesture-pos "vocab:game_lib_test/resources/O.png" set-cell drop relayout-1 ] ;

:: on-click ( gadget -- value )
    [ 
        gadget rules>>
        [ gadget board>> gadget gesture-pos X set-cell drop f >>rules drop ]
        [ gadget board>> gadget gesture-pos O set-cell drop t >>rules drop ]
        if
    ] ;

! TODO: incorporate this check for every loop once game loop is ready
:: row-win ( board -- seq )
    ! Returns true if either X or O has a row win
    ! For each row, check if every element in specified row equals X, returning true if any row meets the condition
    { 0 1 2 } [ X swap board swap get-row all-equal-value? ] any?
    ! Same check but with O
    { 0 1 2 } [ O swap board swap get-row all-equal-value? ] any? or ;

:: col-win ( board -- ? )
    ! Same as row win except checks column wins
    { 0 1 2 } [ X swap board swap get-col all-equal-value? ] any?
    { 0 1 2 } [ O swap board swap get-col all-equal-value? ] any? or ;

:: diag-win ( board -- ? )
    ! Same as row win except checks diagonal wins
    X board { { 0 0 } { 1 1 } { 2 2 } } get-multicell all-equal-value?
    X board { { 2 0 } { 1 1 } { 0 2 } } get-multicell all-equal-value? or
    O board { { 0 0 } { 1 1 } { 2 2 } } get-multicell all-equal-value? or
    O board { { 2 0 } { 1 1 } { 0 2 } } get-multicell all-equal-value? or ;

:: check-win ( board -- ? )
    ! Returns true if any win condition is met
    board row-win board col-win or board diag-win or ;

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

:: <game-state> ( gadget -- gadget game-state )
    game-state new 
    gadget >>gadget
    f >>p1
    gadget f set-rules swap ;

    
! --------------------- Game Loop things -----------------------------------------------------

! ----------------------- Goes in the Library---------------------------------------------------------------------
: new-game-loop ( interval game-state -- game-loop )
    <game-loop> dup tictactoe-game-loop set ;

: stop-game ( -- )
    tictactoe-game-loop get stop-loop ;

! ----------------------------------------------------------------------------------------------------------------

: create-loop ( game-state -- )
    1000000000 swap new-game-loop start-loop ;


: tick-update ( game-state -- game-state )
    dup gadget>> board>> check-win 
    [ dup gadget>> relayout-1 stop-game ] 
    [ dup gadget>> relayout-1 ] if ;


M: game-state tick* tick-update drop ;

M: game-state draw* drop drop ;

! ----------------------------------------------------------------------------------------------

: display-window ( -- )
    { 400 200 } init-window ! initialize the window with dimensions
    draw ! optional function to draw rectangles or sprites
    board ! optional function to create a board

    gestures ! sets gestures -- a hashmap of key presses and associated actions

    COLOR: purple { 2 0 } { 100 100 } draw-filled-rectangle 
    
    <game-state> ! sets the game-state and leaves it on the stack for the creation of the loop
  
    create-loop ! creates and starts the game loop


    display ; ! call display to see the window

    ! note: using relayout seems to change the window correctly


MAIN: display-window