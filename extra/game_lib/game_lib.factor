USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl sequences ;

IN: game_lib

TUPLE: window-gadget < gadget dimension bg-color objects ;

:: display ( gadget -- )
    [ 
        gadget
        "Display window"
        open-status-window 
    ] with-ui ;

: set-background-color ( gadget color -- gadget )
    >>bg-color ;

: init-window ( dim -- gadget )
    window-gadget new
    swap >>dimension 
    COLOR: white set-background-color ;

! Getting error when using call in draw-gadget? 
:: draw-rect ( gadget origin dim color -- gadget )
    gadget [ color gl-color origin dim gl-fill-rect ] >>objects ;

M: window-gadget pref-dim*
   dimension>> ;

M: window-gadget draw-gadget*
    dup bg-color>> gl-color dimension>>
    { 0 0 } swap gl-fill-rect ;
    ! objects>> call ;
    ! [ COLOR: pink gl-color { 0 0 } { 10 10 } gl-fill-rect ] call ;
