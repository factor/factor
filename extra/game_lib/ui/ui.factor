USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl sequences combinators peg
images.loader opengl.textures assocs math math.ranges game_lib.board ui.gestures ;

IN: game_lib.ui

! dimension -- { width height } of window
! draw-quotes is a sequence of quotes, where each quote is an instruction on how to draw something
! board -- board object created from board library
TUPLE: window-gadget < gadget dimension bg-color draw-quotes board gests rules ;

TUPLE: sprite image loc dim ;


! SECTION: These functions are what the user calls
: set-background-color ( gadget color -- gadget )
    >>bg-color ;

: init-window ( dim -- gadget )
    ! makes a window gadget with given dimensions
    window-gadget new
    swap >>dimension 
    H{ } >>gests ;

: create-board ( gadget board -- gadget )
    >>board ;

: set-rules ( gadget rules -- gadget )
    >>rules ;

: check-rules ( gadget -- ? )
    rules>> t? ;

:: draw-filled-rectangle ( gadget color loc dim -- gadget )
    ! appends instruction to draw a rectangle to current set of instructions in draw-quotes attribute
    gadget 
    gadget draw-quotes>> 
    [ color gl-color loc dim gl-fill-rect ] { } 1sequence append
    >>draw-quotes ;

:: draw-image ( gadget path loc dim -- gadget )
    ! appends instructions to draw a sprite to current set of instructions in draw-quotes attributes
    gadget 
    gadget draw-quotes>> 
    [ dim path load-image loc <texture> draw-scaled-texture ] { } 1sequence append
    >>draw-quotes ;

:: display ( gadget -- )
    [ 
        gadget
        "Display window"
        open-status-window 
    ] with-ui ;

! SECTION: These functions does the logic behind the hood
:: <sprite> ( path loc dim -- sprite )
    ! creates a sprite object if given a path, otherwise set sprite as false
    path
    [
        sprite new path load-image >>image loc >>loc dim >>dim 
    ] [
        f
    ] if ;

! TODO: use the cache and handle cells that are false
:: all-combinations ( seq1 seq2 -- matrix )
    ! converts two sequences into a matrix of pairs 
    ! ex: { 0 1 2 } { 4 5 6 7 } -> 
    ! {
    !     { { 0 4 } { 1 4 } { 2 4 } }
    !     { { 0 5 } { 1 5 } { 2 5 } }
    !     { { 0 6 } { 1 6 } { 2 6 } }
    !     { { 0 7 } { 1 7 } { 2 7 } }
    ! }

    seq1 seq2 [ seq1 length swap [ ] curry replicate over swap zip ] map 
    swap drop ;

:: get-cell-dimension ( gadget -- celldims )
    ! Calculates cell height and width based on gadget height and width
    gadget dimension>> first2 :> ( wdt hgt )
    gadget board>> dup width>> swap height>> :> ( cols rows )

    wdt cols /i :> cellwidth 
    hgt rows /i :> cellheight

   cellwidth cellheight { } 2sequence ;

:: get-dimension-matrix ( gadget -- matrix )
    ! gets a matrix of all starting locations of cells
    gadget get-cell-dimension :> celldims
    ! applies appropriate offset to starting locations based on the cell heigh/width
    gadget board>> width>> [0..b) [ celldims first * ] map :> widths
    gadget board>> height>> [0..b) [ celldims second * ] map :> heights

    widths heights all-combinations ;

 :: draw-single-image ( image-params -- )
    ! if the sprite is valid, draw the sprite
    image-params
    [
        image-params dim>> image-params image>> image-params loc>> <texture> draw-scaled-texture 
    ] [

    ] if ;

:: draw-cells ( gadget -- )
    ! if the board is valid, draw the sprite at every starting location
    gadget board>>
    [
        gadget get-cell-dimension :> celldims
        gadget get-dimension-matrix :> dim-matrix
        gadget board>> cells>> dim-matrix [ [ celldims <sprite> draw-single-image ] 2each ] 2each
    ] [
        
    ] if ;


:: draw-background-color ( gadget -- )
    ! if given a background color, draw the background color
    gadget bg-color>> 
    [
        gadget bg-color>> gl-color { 0 0 } gadget dimension>> gl-fill-rect
    ] [
        
    ] if ;

: draw-background ( gadget -- )
    ! draws everything in draw-quotes (which we added to using draw-filled-rectangle and draw-image)
    draw-quotes>> [ call( -- ) ] each ;

:: gesture-pos ( gadget -- cell-pos )
    gadget hand-rel first2 :> ( w h )
    gadget get-cell-dimension first2 :> ( cw ch )
    w cw /i :> row
    h ch /i :> col
    row col { } 2sequence ;

:: new-gestures ( gadget value key -- gadget )
    value key gadget gests>> set-at gadget ;

:: make-gestures ( gadget -- gadget )
    window-gadget gadget gests>> set-gestures gadget ;

! SECTION: gadget methods
M: window-gadget pref-dim*
   dimension>> ;

M: window-gadget draw-gadget*
    {
        ! Background
        [ draw-background-color ]
        [ draw-background ]
        ! Board
        [ draw-cells ]
    } cleave ;


