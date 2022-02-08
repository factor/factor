USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl sequences combinators peg
images.loader opengl.textures assocs math math.ranges game_lib.board ;

IN: game_lib

TUPLE: window-gadget < gadget dimension bg-color rects-params images-params board ;

TUPLE: rect color loc dim ;

TUPLE: sprite image loc dim ;

:: <sprite> ( path loc dim -- sprite )
    path
    [
        sprite new path load-image >>image loc >>loc dim >>dim 
    ] [
        f
    ] if ;

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
    ! 3 3 "vocab:game_lib_test/resources/X.png" make-board >>board
    COLOR: white set-background-color ;

: create-board ( gadget x y path -- gadget )
    make-board >>board ;

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
    path loc dim <sprite> { } 1sequence append
    ! sprite new path load-image >>image loc >>loc dim >>dim { } 1sequence append
    >>images-params ;

! TODO: use the cache and handle cells that are false
:: draw-single-image ( image-params -- )
    image-params
    [
        image-params dim>> image-params image>> image-params loc>> <texture> draw-scaled-texture 
    ] [

    ] if ;

: draw-images ( images-params -- )
    [ draw-single-image ] each ;

:: all-combinations ( seq1 seq2 -- matrix )
    seq1 seq2 [ seq1 length swap [ ] curry replicate over swap zip ] map 
    swap drop ;

:: get-cell-dimension ( gadget -- celldims )
    ! Calculates cell height and width based on gadget height and width
    gadget dimension>> first2 :> ( wdt hgt )
    gadget board>> dup width>> swap height>> :> ( cols rows )

    wdt cols / :> cellwidth 
    hgt rows / :> cellheight

   cellwidth cellheight { } 2sequence ;

:: get-dimension-matrix ( gadget -- matrix )
    gadget get-cell-dimension :> celldims
    gadget board>> width>> [0..b) [ celldims first * ] map :> widths
    gadget board>> height>> [0..b) [ celldims second * ] map :> heights

    widths heights all-combinations ;

:: draw-cells ( gadget -- )
    gadget get-cell-dimension :> celldims
    gadget get-dimension-matrix :> dim-matrix
    gadget board>> cells>> dim-matrix [ [ celldims <sprite> draw-single-image ] 2each ] 2each ;

    ! gadget board>> ;

: flatten ( -- ) 
;


M: window-gadget pref-dim*
   dimension>> ;

M: window-gadget draw-gadget*
    {
        ! Background
        [ draw-background ]
        [ rects-params>> draw-rects ] 
        [ images-params>> draw-images ]
        ! Board
        [ draw-cells ]
    } cleave ;

