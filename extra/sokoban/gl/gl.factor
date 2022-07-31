! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators math.vectors
kernel math opengl opengl.gl opengl.textures sequences sokoban.game sokoban.piece images.loader
;

IN: sokoban.gl

! OpenGL rendering for sokoban ;

: draw-block ( block -- )
    { 1 1 } gl-fill-rect ;

: draw-sprite ( block path -- )
    load-image swap <texture> { 1 1 } swap draw-scaled-texture ;

:: draw-piece-blocks ( piece -- )
    piece piece-blocks [ piece path>> draw-sprite ] each ;

: draw-piece ( piece -- )
    dup layout>> color>> gl-color draw-piece-blocks ;

: draw-goal ( block -- )
    { 0.38 0.38 } v+ { 0.24 0.24 } gl-fill-rect ;

: draw-goal-blocks ( piece -- )
    ! implement goals the same way we do as walls
    wall-blocks [ draw-goal ] each ;

: draw-goal-piece ( piece -- )
    dup layout>> color>> gl-color draw-goal-blocks ;

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
            [ player>> draw-piece ]
            [ goals>> draw-goal-piece ]
            [ boxes>> [ draw-piece ] each ]
        } cleave
    ] do-matrix ;
