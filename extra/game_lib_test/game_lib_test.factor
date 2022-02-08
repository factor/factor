USING: accessors kernel game_lib colors.constants ui.gadgets ;

IN: game_lib_test

: draw ( gadget -- gadget )
    COLOR: pink set-background-color ! defaults to white if not set
    COLOR: green { 0 0 } { 150 150 } draw-filled-rectangle ! draws this first
    COLOR: blue { 0 0 } { 100 100 } draw-filled-rectangle
    "vocab:game_lib_test/resources/X.png" { 20 40 } { 20 20 } draw-image
    "vocab:game_lib_test/resources/O.png" { 60 40 } { 20 20 } draw-image ;


: display-window ( -- )
    { 400 200 } init-window ! initialize the window with dimensions
    ! draw ! optional function to draw rectangles or sprites
    3 3 "vocab:game_lib_test/resources/X.png" create-board ! takes up the entire screen as of now
    display ; ! call display to see the window

    ! note: using relayout seems to change the window correctly

MAIN: display-window