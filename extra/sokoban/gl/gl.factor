! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors colors.constants combinators
kernel math opengl opengl.gl sequences sokoban.game sokoban.piece
;

IN: sokoban.gl

! OpenGL rendering for sokoban

: draw-block ( block -- )
    { 1 1 } gl-fill-rect ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-piece ( piece -- )
    dup tetromino>> colour>> gl-color draw-piece-blocks ;

: draw-next-piece ( piece -- )
    dup tetromino>> colour>>
    >rgba-components drop 0.2 <rgba> gl-color draw-piece-blocks ;

! TODO: move implementation specific stuff into sokoban-board
: (draw-row) ( x y row -- )
    overd nth [ gl-color 2array draw-block ] [ 2drop ] if* ;

: draw-row ( y row -- )
    [ length <iota> swap ] keep [ (draw-row) ] 2curry each ;

: draw-board ( board -- )
    rows>> [ swap draw-row ] each-index ;

: scale-board ( width height board -- )
    [ width>> ] [ height>> ] bi swapd [ / ] dup 2bi* 1 glScalef ;

: set-background-color ( sokoban -- )
    dup running?>> [
        paused?>> COLOR: light-gray COLOR: white ?
    ] [ drop COLOR: black ] if gl-color ;

: draw-background ( board -- )
    [ 0 0 ] dip [ width>> ] [ height>> ] bi glRectf ;

: draw-sokoban ( width height sokoban -- )
    ! width and height are in pixels
    [
        {
            [ board>> scale-board ]
            [ set-background-color ]
            [ board>> draw-background ]
            [ board>> draw-board ]
            [ next-piece draw-next-piece ]
            [ current-piece draw-piece ]
        } cleave
    ] do-matrix ;
