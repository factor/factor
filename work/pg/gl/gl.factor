! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel math math.vectors
namespaces opengl opengl.gl sequences pg.board pg.game
pg.piece ui.render pg.tetromino ui.gadgets colors ;
IN: pg.gl

! OpenGL rendering for pg

: draw-block ( block -- )
    { 1 1 } gl-fill-rect ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-piece ( piece -- )
    dup tetromino>> colour>> gl-color draw-piece-blocks ;

: draw-next-piece ( piece -- )
    dup tetromino>> colour>>
    >rgba-components drop 0.2 <rgba> gl-color draw-piece-blocks ;

! TODO: move implementation specific stuff into pg-board
: (draw-row) ( x y row -- )
    [ over ] dip nth dup
    [ gl-color 2array draw-block ] [ 3drop ] if ;

: draw-row ( y row -- )
    [ length iota swap ] keep [ (draw-row) ] 2curry each ;

: draw-board ( board -- )
    rows>> [ length iota ] keep
    [ dupd nth draw-row ] curry each ;

: scale-board ( width height board -- )
    [ width>> ] [ height>> ] bi swapd [ / ] dup 2bi* 1 glScalef ;

: draw-pg ( width height pg -- )
    ! width and height are in pixels
    [
        {
            [ board>> scale-board ]
            [ board>> draw-board ]
            [ next-piece draw-next-piece ]
            [ current-piece draw-piece ]
        } cleave
    ] do-matrix ;
