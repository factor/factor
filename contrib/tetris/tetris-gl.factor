! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays math namespaces opengl gadgets tetris tetris-board tetris-piece tetromino ;
IN: tetris-gl

#! OpenGL rendering for tetris

: draw-block ( block -- )
    dup { 1 1 } v+ gl-fill-rect ;

: draw-piece-blocks ( piece -- )
    piece-blocks [ draw-block ] each ;

: draw-piece ( piece -- )
    dup tetromino-colour gl-color draw-piece-blocks ;

: draw-next-piece ( piece -- )
    dup tetromino-colour clone 0.1 3 pick set-nth gl-color draw-piece-blocks ;

! TODO: move implementation specific stuff into tetris-board
: (draw-row) ( y row x -- y )
    swap dupd nth [ gl-color over 2array draw-block ] [ drop ] if* ;

: draw-row ( y row -- )
    dup length [ (draw-row) ] each-with drop ;

: draw-board ( board -- )
    board-rows dup length [ tuck swap nth draw-row ] each-with ;

: scale-tetris ( width height tetris -- )
    [ board-width swap ] keep board-height / -rot / swap 1 glScalef ;

: (draw-tetris) ( width height tetris -- )
    #! width and height are in pixels
    GL_MODELVIEW [
        [ scale-tetris ] keep
	GL_COLOR_BUFFER_BIT glClear
	dup tetris-board draw-board
        dup tetris-next-piece draw-next-piece
	tetris-current-piece draw-piece
    ] do-matrix ;

: draw-tetris ( width height tetris -- )
    origin get [ (draw-tetris) ] with-translation ;
