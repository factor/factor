! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors colors.constants combinators
kernel math opengl opengl.gl sequences sokoban.game sokoban.piece
;

IN: sokoban.gl

! OpenGL rendering for sokoban 

: draw-block ( block -- )
    { 1 1 } gl-fill-rect ;


: draw-wall-blocks ( piece -- )
    wall-blocks [ draw-block ] each ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-walls ( piece -- )
    dup tetromino>> color>> gl-color draw-wall-blocks ;

: draw-piece ( piece -- )
    dup tetromino>> color>> gl-color draw-piece-blocks ;

: draw-goal ( block -- )
    { .25 .25 } gl-fill-rect ;

: draw-goal-blocks ( piece -- )
    ! implement goals the same way we do as walls
    wall-blocks [ draw-goal ] each ;

: draw-goal-piece ( piece -- )
    dup tetromino>> color>> gl-color draw-goal-blocks ;


! : draw-next-piece ( piece -- )
    ! dup tetromino>> color>>
    ! >rgba-components drop 0.2 <rgba> gl-color draw-piece-blocks ;

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
            ! [ next-piece draw-next-piece ]
            [ current-piece draw-piece ]
            [ boxes>> [ draw-piece ] each ]
            [ goals>> draw-goal-piece ]
        } cleave
    ] do-matrix ;
