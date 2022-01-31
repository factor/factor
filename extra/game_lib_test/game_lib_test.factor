USING: accessors kernel game_lib colors.constants ui.gadgets ;

IN: game_lib_test

: display-window ( -- )
    ! initialize the window
    { 200 200 } init-window 
    COLOR: blue set-background-color ! defaults to white if not set
    ! trying to add more objects to draw
    ! { 0 0 } { 100 100 } COLOR: black draw-rect 
    display ; ! call display to see the window
    ! using relayout seems to change the window correctly
    ! { 500 600 } COLOR: red <gadget>
    ! relayout ;

MAIN: display-window