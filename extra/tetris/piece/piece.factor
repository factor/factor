! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.vectors sequences
tetris.tetromino lists.lazy ;
IN: tetris.piece

! The rotation is an index into the tetromino's states array,
! and the position is added to the tetromino's blocks to give
! them their location on the tetris board. If the location is f
! then the piece is not yet on the board.

TUPLE: piece
    { tetromino tetromino }
    { rotation integer initial: 0 }
    { location array initial: { 0 0 } } ;

: <piece> ( tetromino -- piece )
    piece new swap >>tetromino ;

: (piece-blocks) ( piece -- blocks )
    ! rotates the piece
    [ rotation>> ] [ tetromino>> states>> ] bi nth ;

: piece-blocks ( piece -- blocks )
    ! rotates and positions the piece
    [ (piece-blocks) ] [ location>> ] bi [ v+ ] curry map ;

: piece-width ( piece -- width )
    piece-blocks blocks-width ;

: set-start-location ( piece board-width -- piece )
    over piece-width [ 2 /i ] bi@ - 0 2array >>location ;

: <random-piece> ( board-width -- piece )
    random-tetromino <piece> swap set-start-location ;

: <piece-llist> ( board-width -- llist )
    [ [ <random-piece> ] curry ] keep [ <piece-llist> ] curry lazy-cons ;

: (rotate-piece) ( rotation inc n-states -- rotation' )
    [ + ] dip rem ;

: rotate-piece ( piece inc -- piece )
    over tetromino>> states>> length
    [ (rotate-piece) ] 2curry change-rotation ;

: move-piece ( piece move -- piece )
    [ v+ ] curry change-location ;
