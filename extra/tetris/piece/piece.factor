! Copyright (C) 2006, 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays tetris.tetromino math math.vectors 
sequences quotations lazy-lists ;
IN: tetris.piece

#! A piece adds state to the tetromino that is the piece's delegate. The
#! rotation is an index into the tetromino's states array, and the position is
#! added to the tetromino's blocks to give them their location on the tetris
#! board. If the location is f then the piece is not yet on the board.
TUPLE: piece rotation location ;

: <piece> ( tetromino -- piece )
    piece construct-delegate
    0 over set-piece-rotation
    { 0 0 } over set-piece-location ;

: (piece-blocks) ( piece -- blocks )
    #! rotates the tetromino
    dup piece-rotation swap tetromino-states nth ;

: piece-blocks ( piece -- blocks )
    #! rotates and positions the tetromino
    dup (piece-blocks) swap piece-location [ v+ ] curry map ;

: piece-width ( piece -- width )
    piece-blocks blocks-width ;

: set-start-location ( piece board-width -- )
    2 /i over piece-width 2 /i - 0 2array swap set-piece-location ;

: <random-piece> ( board-width -- piece )
    random-tetromino <piece> [ swap set-start-location ] keep ;

: <piece-llist> ( board-width -- llist )
    [ [ <random-piece> ] curry ] keep [ <piece-llist> ] curry lazy-cons ;

: modulo ( n m -- n )
  #! -2 7 mod => -2, -2 7 modulo =>  5
  tuck mod over + swap mod ;

: rotate-piece ( piece inc -- )
    over piece-rotation + over tetromino-states length modulo swap set-piece-rotation ;

: move-piece ( piece move -- )
    over piece-location v+ swap set-piece-location ;

