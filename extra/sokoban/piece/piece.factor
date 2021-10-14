! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.vectors sequences
sokoban.tetromino lists.lazy namespaces ;
IN: sokoban.piece

! The rotation is an index into the tetromino's states array,
! and the position is added to the tetromino's blocks to give
! them their location on the sokoban board. If the location is f
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

: set-board-location ( piece board-width -- piece )
    drop ;

: set-player-location ( piece board-width -- piece )
    drop 0 startinglocs get first nth >>location ;

: set-box-location ( piece board-width -- piece )
    ! sets the location of the boxes to where they are defined in tetromino
    !                               this first will be replaced with nth for levels
    drop 0 over tetromino>> states>> nth first >>location ;
    ! {0,0} o >>states  ; 
    ! sets the local position (in tetromino) to 0,0
    
    ! 0 here is the level number 
    ! TODO: add level arg, remove board-width arg from all of these

: set-goal-location ( piece board-width -- piece )
    drop 0 startinglocs get third nth >>location ;


: <board-piece> ( board-width -- piece )
    get-board <piece> swap set-board-location ;

: <player-piece> ( board-width -- piece )
    get-player <piece> swap set-player-location ;

: <box-piece> ( board-width -- piece )
    get-box <piece> swap set-box-location ;

: <goal-piece> ( board-width -- piece )
    get-goal <piece> swap set-goal-location ;

: <player-llist> ( board-width -- llist )
    [ [ <player-piece> ] curry ] keep [ <player-llist> ] curry lazy-cons ;

: <piece-llist> ( board-width -- llist )
    [ [ <board-piece> ] curry ] keep [ <piece-llist> ] curry lazy-cons ;

: <box-llist> ( board-width -- llist )
    [ [ <box-piece> ] curry ] keep [ <box-llist> ] curry lazy-cons ;

: <goal-llist> ( board-width -- llist )
    [ [ <goal-piece> ] curry ] keep [ <box-llist> ] curry lazy-cons ;

: (rotate-piece) ( rotation inc n-states -- rotation' )
    [ + ] dip rem ;

: rotate-piece ( piece inc -- piece )
    over tetromino>> states>> length
    [ (rotate-piece) ] 2curry change-rotation ;

: move-piece ( piece move -- piece )
    [ v+ ] curry change-location ;
