USING: accessors kernel game_lib colors.constants ui.gadgets ;

IN: game_lib_test

: display-window ( -- )
    ! initialize the window with dimensions and drawn objects (works only with rectangles for now)
    { 200 200 } init-window 
    COLOR: pink set-background-color ! defaults to white if not set
    COLOR: black { 0 0 } { 150 150 } draw-rectangle ! draws this first
    COLOR: gray { 0 0 } { 100 100 } draw-rectangle
    display ; ! call display to see the window

    ! using relayout seems to change the window correctly

MAIN: display-window