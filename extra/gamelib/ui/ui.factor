USING: accessors arrays classes quotations ui.gadgets kernel
ui.gadgets.status-bar ui ui.render opengl locals.types strings
sequences combinators peg images.loader opengl.textures assocs
math ranges gamelib.board gamelib.cell-object ui.gestures
ui.gadgets.tracks ui.gadgets.worlds colors destructors
gamelib.loop ;

IN: gamelib.ui

TUPLE: board-gadget < gadget dimension bg-color draw-quotes board gests textures ;

:: get-cell-dimension ( n gadget -- celldims )
    ! Calculates cell height and width based on gadget height and width
    gadget dimension>> first2 :> ( wdt hgt )
    n gadget board>> nth dup width>> swap height>> :> ( cols rows )

    wdt cols /i :> cellwidth 
    hgt rows /i :> cellheight

    cellwidth cellheight { } 2sequence ;

:: get-dimension-matrix ( n gadget -- matrix )
    ! gets a matrix of all starting locations of cells
    n gadget get-cell-dimension :> celldims
    ! applies appropriate offset to starting locations based on the cell heigh/width
    n gadget board>> nth width>> [0..b) [ celldims first * ] map :> widths
    n gadget board>> nth height>> [0..b) [ celldims second * ] map :> heights

    widths heights cartesian-product flip ;

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
    gadget [ dim { path loc } gadget textures>> [ first load-image loc <texture> ] cache draw-scaled-texture ] draw-append ;
    ! gadget [ dim path load-image loc <texture> draw-scaled-texture ] draw-append ;

:: draw-quote ( gadget quote -- gadget )
    gadget quote draw-append ;

:: draw-single ( display-cell loc dim gadget -- )
    ! Executes instructions based on content of the cell, does nothing if cell isn't a 
    ! string, color or quote.
    { 
        { [ display-cell cell-object instance? ] [ loc dim display-cell draw-cell-object* ] }
        { [ display-cell string? ] [ dim { display-cell loc } gadget textures>> [ first load-image loc <texture> ] cache draw-scaled-texture ] }
        { [ display-cell color? ] [ display-cell gl-color loc dim gl-fill-rect ] }
        { [ display-cell quotation? ] [ loc dim display-cell 2curry call( -- ) ] }
        { [ display-cell array? ] [ display-cell [ loc dim gadget draw-single ] each ] }
        [ ]
    } cond ;

:: draw-cells ( n gadget -- )
    ! board is always valid since this instruction gets added on creation of board
    n gadget board>> nth cells>> :> cell
    n gadget get-cell-dimension :> celldims
    n gadget get-dimension-matrix :> dim-matrix
    cell dim-matrix [ [ celldims gadget draw-single ] 2each ] 2each ;

: draw-all ( gadget -- )
    ! draws everything in draw-quotes (which we added to using draw-filled-rectangle and draw-image)
    draw-quotes>> [ call( -- ) ] each ;

! TODO: change to have a board
: init-board-gadget ( dim -- gadget )
    ! makes a window gadget with given dimensions
    board-gadget new
    swap >>dimension 
    H{ } >>gests 
    H{ } clone >>textures ;

:: add-board ( gadget board -- gadget )
    ! board should be a seq
    gadget board >>board
    [ board length [0..b) [ gadget draw-cells ] each ] draw-append ;

:: display ( gadget -- )
    [ 
        gadget
        "Display window"
        open-status-window 
    ] with-ui ;

: set-background-color ( gadget color -- gadget )
    >>bg-color ;

: set-dim ( gadget dim -- gadget )
    >>dimension ;

: get-dim ( gadget -- dim )
    dimension>> ;

:: hand-rel-cell ( gadget -- cellpos )
    gadget hand-rel first2 :> ( w h )
    0 gadget get-cell-dimension first2 :> ( cw ch )
    w cw /i :> row
    h ch /i :> col
    row col { } 2sequence ;

:: new-gesture ( gadget key value -- gadget )
    value key gadget gests>> set-at gadget ;


! SECTION: gadget methods
M: board-gadget pref-dim*
    dimension>> ;

M: board-gadget handle-gesture
    swap over gests>> ?at
    [
        2dup call( gadget -- )
    ] when 2drop f ;

M: board-gadget draw-gadget*
    {
        [ draw-background-color ]
        [ draw-all ]
    } cleave ;

M: board-gadget ungraft*
    [   dup find-gl-context [ values dispose-each H{ } clone ] change-textures drop
        stop-game
    ] [ call-next-method ] bi ; 

TUPLE: window-gadget < track focusable-child-number ;

:: <window> ( board-gadgets orientation fsn constraint -- gadget )
    orientation window-gadget new-track 
    fsn >>focusable-child-number
    board-gadgets [ constraint track-add ] each ;

M: window-gadget focusable-child* dup children>> swap focusable-child-number>> swap nth ;
