USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl sequences combinators peg
images.loader opengl.textures assocs ;

IN: game_lib

TUPLE: window-gadget < gadget dimension bg-color rects-params images-params board;

TUPLE: rect color loc dim ;

TUPLE: sprite image loc dim ;

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

:: draw-background ( gadget -- )
    gadget bg-color>> gl-color 
    { 0 0 } gadget dimension>> ! colors the full screen
    gl-fill-rect ;

! adds new rectangle parameters to rects-params as a tuple
:: draw-filled-rectangle ( gadget color loc dim -- gadget )
    gadget 
    gadget rects-params>> 
    rect new color >>color loc >>loc dim >>dim { } 1sequence append
    >>rects-params ;

! extracts parameter tuple and draws the rectangle
:: draw-single-rect ( rect-params -- )
    rect-params color>> gl-color rect-params loc>> rect-params dim>> gl-fill-rect ;

! draws every rectangle in rects-params
: draw-rects ( rects-params -- )
    [ draw-single-rect ] each ;

:: draw-image ( gadget path loc dim -- gadget )
    gadget 
    gadget images-params>> 
    sprite new path load-image >>image loc >>loc dim >>dim { } 1sequence append
    >>images-params ;

! TODO: use the cache
:: draw-single-image ( image-params -- )
    image-params dim>> image-params image>> image-params loc>> <texture> draw-scaled-texture ;

: draw-images ( images-params -- )
    [ draw-single-image ] each ;

:: meshgrid ( seq1 seq2 -- seq3 )
    seq1 seq2 [ seq1 length swap [ ] curry replicate over zip ] map 
    swap drop ;


:: draw-cells ( gadget -- )
    ;

M: window-gadget pref-dim*
   dimension>> ;

M: window-gadget draw-gadget*
    {
        [ draw-background ]
        [ draw-cells ]
        [ rects-params>> draw-rects ] 
        [ images-params>> draw-images ]
    } cleave ;

