USING: accessors ui.gadgets kernel ui.gadgets.status-bar ui ui.render colors.constants opengl locals.types strings sequences combinators peg
images.loader opengl.textures assocs math math.ranges game_lib.board ui.gestures colors ;

IN: game_lib.ui

TUPLE: window-gadget < gadget dimension bg-color draw-quotes board gests rules ;

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

:: draw-append ( gadget quot -- gadget )
    gadget
    gadget draw-quotes>> 
    quot { } 1sequence append
    >>draw-quotes ;

:: draw-background-color ( gadget -- )
    ! if given a background color, draw the background color
    gadget bg-color>> 
    [ gadget bg-color>> gl-color { 0 0 } gadget dimension>> gl-fill-rect ] 
    [ ] if ;

:: draw-filled-rectangle ( gadget color loc dim -- gadget )
    ! appends instruction to draw a rectangle to current set of instructions in draw-quotes attribute
    gadget [ color gl-color loc dim gl-fill-rect ] draw-append ;

:: draw-image ( gadget path loc dim -- gadget )
    ! appends instructions to draw a sprite to current set of instructions in draw-quotes attributes
    gadget [ dim path load-image loc <texture> draw-scaled-texture ] draw-append ;

:: draw-quote ( gadget quote -- gadget )
    gadget quote draw-append ;

:: draw-single ( cell loc dim -- )
    ! Executes instructions based on content of the cell, does nothing if cell isn't a 
    ! string, color or quote.
    { 
        { [ cell string? ] [ dim cell load-image loc <texture> draw-scaled-texture ] }
        { [ cell color? ] [ cell gl-color loc dim gl-fill-rect ] }
        { [ cell quote? ] [ cell call( -- ) ] }
        [ ]
    } cond ;

:: draw-cells ( gadget -- )
    ! board is always valid since this instruction gets added on creation of board
    gadget board>> cells>> :> cell
    gadget get-cell-dimension :> celldims
    gadget get-dimension-matrix :> dim-matrix
    cell dim-matrix [ [ celldims draw-single ] 2each ] 2each ;

: draw-all ( gadget -- )
    ! draws everything in draw-quotes (which we added to using draw-filled-rectangle and draw-image)
    draw-quotes>> [ call( -- ) ] each ;

: init-window ( dim -- gadget )
    ! makes a window gadget with given dimensions
    window-gadget new
    swap >>dimension 
    H{ } >>gests ;

:: create-board ( gadget board -- gadget )
    gadget board >>board
    [ gadget draw-cells ] draw-append ;

:: display ( gadget -- )
    [ 
        gadget
        "Display window"
        open-status-window 
    ] with-ui ;

: set-background-color ( gadget color -- gadget )
    >>bg-color ;

: set-rules ( gadget rules -- gadget )
    >>rules ;

: check-rules ( gadget -- ? )
    rules>> t? ;

: get-dim ( gadget -- dim )
    dim>> ;

:: gesture-pos ( gadget -- cellpos )
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
        [ draw-all ]
    } cleave ;


