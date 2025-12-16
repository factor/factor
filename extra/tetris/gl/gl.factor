! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays colors combinators kernel math namespaces
opengl opengl.gl sequences tetris.game tetris.piece ;

IN: tetris.gl

! OpenGL rendering for tetris

: draw-block ( block -- )
    { 1 1 } gl-fill-rect ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-piece ( piece -- )
    dup tetromino>> color>> gl-color draw-piece-blocks ;

: draw-next-piece ( piece -- )
    dup tetromino>> color>>
    >rgba-components drop 0.2 <rgba> gl-color draw-piece-blocks ;

! TODO: move implementation specific stuff into tetris-board
: (draw-row) ( x y row -- )
    overd nth [ gl-color 2array draw-block ] [ 2drop ] if* ;

: draw-row ( y row -- )
    [ length <iota> swap ] keep [ (draw-row) ] 2curry each ;

: draw-board ( board -- )
    rows>> [ swap draw-row ] each-index ;

: scale-board ( width height board -- )
    [ width>> ] [ height>> ] bi swapd [ / ] dup 2bi* gl-scale-2d ;

: set-background-color ( tetris -- )
    dup running?>> [
        paused?>> COLOR: light-gray COLOR: white ?
    ] [ drop COLOR: black ] if gl-color ;

: draw-background ( board -- )
    [ 0 0 ] dip [ width>> ] [ height>> ] bi gl-rectf ;

: draw-tetris ( width height tetris -- )
    ! width and height are in logical pixels
    ! Projection handles scaling to device pixels
    '[
        _ _ _ {
            [ board>> scale-board ]
            [ set-background-color ]
            [ board>> draw-background ]
            [ board>> draw-board ]
            [ next-piece draw-next-piece ]
            [ current-piece draw-piece ]
        } cleave
    ] with-matrix ;
