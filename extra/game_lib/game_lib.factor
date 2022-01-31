USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl sequences combinators peg ;

IN: game_lib

TUPLE: window-gadget < gadget dimension bg-color boxes-params ;

TUPLE: box color loc dim ;

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

! adds new rectangle parameters to boxes-params as a tuple
:: draw-rectangle ( gadget color loc dim -- gadget )
    gadget 
    gadget boxes-params>> 
    box new color >>color loc >>loc dim >>dim { } 1sequence append
    >>boxes-params ;

! extracts parameter tuple and draws the rectangle
:: draw-single-rect ( box-params -- )
    box-params color>> gl-color box-params loc>> box-params dim>> gl-fill-rect ;

! draws every rectangle in boxes-params
: draw-rects ( boxes-params -- )
    [ draw-single-rect ] each ;

M: window-gadget pref-dim*
   dimension>> ;

M: window-gadget draw-gadget*
    { 
        [ boxes-params>> draw-rects ] 
    } cleave ;
