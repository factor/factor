USING: accessors colors gamelib.board gamelib.cell-object
gamelib.ui images.loader kernel literals opengl.textures
sequences namespaces ;

IN: gamelib.demos.sokoban.layouts

CONSTANT: player "vocab:gamelib/demos/sokoban/resources/CharR.png"
CONSTANT: wall "vocab:gamelib/demos/sokoban/resources/Wall_Brown.png"
CONSTANT: goal "vocab:gamelib/demos/sokoban/resources/Goal.png"
CONSTANT: light-crate "vocab:gamelib/demos/sokoban/resources/Crate_Yellow.png"
CONSTANT: dark-crate "vocab:gamelib/demos/sokoban/resources/CrateDark_Yellow.png"

TUPLE: crate-cell < cell-object image-path ;

M: crate-cell draw-cell-object* 
    rot [ image-path>> load-image ] dip <texture> draw-scaled-texture ;

:: make-crate ( image-path -- crate )
    crate-cell new
    image-path crate-cell boa ;

: board-one ( gadget -- gadget )
    8 9 make-board

    { 2 2 } player add-to-cell

    {
                        { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 }
        { 0 2 }                                         { 6 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 }
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 }                                                 { 7 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 }

    } $ wall add-to-cells

    { 

        { 1 6 } { 3 2 } { 4 3 } { 4 4 } { 4 6 } { 3 6 } { 5 6 }
    } $ light-crate make-crate add-copy-to-cells

    {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
    } $ goal add-to-cells 
    
    { } 1sequence add-board ;


: board-two ( gadget -- gadget )
    22 11 make-board
    
    { 11 8 } player add-to-cell

    {
                                        { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
                                        { 4 1 }                         { 8 1 }
                                        { 4 2 }                         { 8 2 }
                        { 2 3 } { 3 3 } { 4 3 }                         { 8 3 } { 9 3 } { 10 3 }
                        { 2 4 }                                                         { 10 4 }
        { 0 5 } { 1 5 } { 2 5 }         { 4 5 }         { 6 5 } { 7 5 } { 8 5 }         { 10 5 }                                              { 16 5 } { 17 5 } { 18 5 } { 19 5 } { 20 5 } { 21 5 }
        { 0 6 }                         { 4 6 }         { 6 6 } { 7 6 } { 8 6 }         { 10 6 } { 11 6 } { 12 6 } { 13 6 } { 14 6 } { 15 6 } { 16 6 }                                     { 21 6 }
        { 0 7 }                                                                                                                                                                            { 21 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 }         { 6 8 } { 7 8 } { 8 8 }         { 10 8 }          { 12 8 } { 13 8 } { 14 8 } { 15 8 } { 16 8 }                                     { 21 8 }
                                        { 4 9 }                                         { 10 9 } { 11 9 } { 12 9 }                            { 16 9 } { 17 9 } { 18 9 } { 19 9 } { 20 9 } { 21 9 }
                                        { 4 10 } { 5 10 } { 6 10 } { 7 10 } { 8 10 } { 9 10 } { 10 10 }  
    } $ wall add-to-cells
    
    {
        { 19 6 } { 20 6 }
        { 19 7 } { 20 7 }
        { 19 8 } { 20 8 }
    } $ goal add-to-cells

    { 
        { 5 2 } { 7 3 } { 5 4 } { 8 4 } { 5 7 } { 2 7 }
    } $ light-crate make-crate add-copy-to-cells

    { } 1sequence 

    add-board ;


: board-three ( gadget -- gadget )
    8 8 make-board
    
    { 1 1 } player add-to-cell

    {
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 } { 7 0 }
        { 0 1 }                                                 { 7 1 }
        { 0 2 }                                                 { 7 2 }
        { 0 3 }                                                 { 7 3 }
        { 0 4 }                                                 { 7 4 }
        { 0 5 }                                                 { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 } { 1 7 } { 2 7 } { 3 7 } { 4 7 } { 5 7 } { 6 7 } { 7 7 }
    } $ wall add-to-cells

    { 2 1 } $ light-crate make-crate add-to-cell

    { 3 1 } $ goal add-to-cell

    { } 1sequence 

    add-board ;
