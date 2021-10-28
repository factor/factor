! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.vectors sequences
sokoban.tetromino lists.lazy namespaces colors colors.constants 
math.ranges random ;
IN: sokoban.piece

! The level_num is an index into the tetromino's states array,
! and the position is added to the tetromino's blocks to give
! them their location on the sokoban board. If the location is f
! then the piece is not yet on the board.

TUPLE: piece
    { tetromino tetromino }
    { level_num integer initial: 0 }
    { location array initial: { 0 0 } } ;

: <piece> ( tetromino -- piece )
    piece new swap >>tetromino ;

: (piece-blocks) ( piece -- blocks )
    ! rotates the piece
    [ level_num>> ] [ tetromino>> states>> ] bi nth ;

: wall-blocks ( piece -- blocks )
    [ (piece-blocks) ] [ location>> ] bi [ v+ ] curry map ;

: piece-blocks ( piece -- blocks )
    ! rotates and positions the piece
    ! [ (piece-blocks) ] [ location>> ] bi [ v+ ] curry map ;
    location>> { } 1sequence ; ! literally just returns the location in a sequence

: piece-width ( piece -- width )
    piece-blocks blocks-width ;

: set-start-location ( piece board-width -- piece )
    over piece-width [ 2 /i ] bi@ - 0 2array >>location ;

: set-board-location ( piece board-width -- piece )
    drop ;

: set-player-location ( piece board-width -- piece )
    drop 0 startinglocs get first nth >>location ;

: set-box-location ( piece -- piece )
    ! sets the location of the boxes to where they are defined in tetromino
    !                               this first will be replaced with nth for levels
    0 over tetromino>> states>> nth first >>location ; 
    ! sets the local position (in tetromino) to 0,0
    
    ! 0 here is the level number 
    ! TODO: add level arg, remove board-width arg from all of these

: reset-box-location ( piece -- piece )
    ! resets box location using startinglocs symbol
    dup tetromino>> dup states>> 0 swap remove-nth startinglocs get second prefix >>states >>tetromino ; 

: set-goal-location ( piece board-width -- piece )
    drop 0 startinglocs get third nth >>location ;

: is-goal? ( location move -- ? )
    v+ startinglocs get third member? ;

: <board-piece> ( board-width -- piece )
    get-board <piece> swap set-board-location ;

: <player-piece> ( board-width -- piece )
    get-player <piece> swap set-player-location ;

: <box-piece> ( n -- piece )
    get-box <piece> set-box-location dup [ tetromino>> ] [ location>> ] bi
    { 0 0 } is-goal?
    [
        COLOR: blue
    ]
    [
        COLOR: orange
    ] if
    >>color drop ;

: <goal-piece> ( board-width -- piece )
    get-goal <piece> swap set-goal-location ;

: <player-llist> ( board-width -- llist )
    [ [ <player-piece> ] curry ] keep [ <player-llist> ] curry lazy-cons ;

: <piece-llist> ( board-width -- llist )
    [ [ <board-piece> ] curry ] keep [ <piece-llist> ] curry lazy-cons ;

: <box-seq> ( board-width -- seq )
    drop 0 get-num-boxes [0,b] [ <box-piece> ] map ;
    ! TODO replace the 0 with level func at some point

: <box-llist> ( board-width -- llist )
    [ [ <box-piece> ] curry ] keep [ <box-llist> ] curry lazy-cons ;

: <goal-llist> ( board-width -- llist )
    [ [ <goal-piece> ] curry ] keep [ <box-llist> ] curry lazy-cons ;

: (rotate-piece) ( level_num inc n-states -- level_num' )
    [ + ] dip rem ;

: rotate-piece ( piece inc -- piece )
    over tetromino>> states>> length
    [ (rotate-piece) ] 2curry change-level_num ;

: move-piece ( piece move -- piece )
    [ v+ ] curry change-location ;
