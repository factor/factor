! Copyright (C) 2006, 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays math math.vectors namespaces
opengl opengl.gl ui.render ui.gadgets tetris.game tetris.board
tetris.piece tetris.tetromino ;
IN: tetris.gl

#! OpenGL rendering for tetris

: draw-block ( block -- )
    dup { 1 1 } v+ gl-fill-rect ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-piece ( piece -- )
    dup tetromino-colour gl-color draw-piece-blocks ;

: draw-next-piece ( piece -- )
    dup tetromino-colour clone 0.2 3 pick set-nth gl-color draw-piece-blocks ;

! TODO: move implementation specific stuff into tetris-board
: (draw-row) ( x y row -- )
    >r over r> nth dup
    [ gl-color 2array draw-block ] [ 3drop ] if ;

: draw-row ( y row -- )
    dup length -rot [ (draw-row) ] 2curry each ;

: draw-board ( board -- )
    board-rows dup length swap
    [ dupd nth draw-row ] curry each ;

: scale-tetris ( width height tetris -- )
    [ board-width swap ] keep board-height / -rot / swap 1 glScalef ;

: (draw-tetris) ( width height tetris -- )
    #! width and height are in pixels
    GL_MODELVIEW [
        [ scale-tetris ] keep
        dup tetris-board draw-board
        dup tetris-next-piece draw-next-piece
        tetris-current-piece draw-piece
    ] do-matrix ;

: draw-tetris ( width height tetris -- )
    origin get [ (draw-tetris) ] with-translation ;
