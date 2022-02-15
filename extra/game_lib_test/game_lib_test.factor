USING: accessors kernel game_lib colors.constants ui.gadgets game_lib.board ui.gestures words assocs ;

IN: game_lib_test

! The user must call init-window with a dimension sequence first, 
! followed by optional draw/board functions, 
! and must call display last to see the window with everything drawn

: gestures ( gadget -- )
    "gestures" [ 
        { 
            T{ button-down { # 1 } } 
            [ dup board>> over gesture-pos "vocab:game_lib_test/resources/X.png" set-cell drop relayout-1 ] 
        } assoc-union 
    ] change-word-prop ;

: draw ( gadget -- gadget )
    COLOR: pink set-background-color
    COLOR: green { 0 0 } { 150 150 } draw-filled-rectangle ! draws this first
    COLOR: blue { 0 0 } { 100 100 } draw-filled-rectangle ;

: board ( gadget -- gadget )
    ! sprites takes up the entire screen and can only draw sprites as of now    
    3 3 f make-board 
    { 2 0 } "vocab:game_lib_test/resources/O.png" set-cell
    { 1 1 } "vocab:game_lib_test/resources/O.png" set-cell
    { 2 2 } "vocab:game_lib_test/resources/X.png" set-cell
    create-board ;

: display-window ( -- )
    { 400 200 } init-window ! initialize the window with dimensions
!    dup gestures ! sets gestures -- a hashmap of key presses and associated actions
    draw ! optional function to draw rectangles or sprites
    board ! optional function to create a board
    display ; ! call display to see the window

    ! note: using relayout seems to change the window correctly

MAIN: display-window