! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.vectors sequences
sokoban.layout lists.lazy namespaces colors
ranges random ;
IN: sokoban.piece

! The level_num is an index into the layout's states array,
! and the position is added to the layout's blocks to give
! them their location on the sokoban board. If the location is f
! then the piece is not yet on the board.

TUPLE: piece
    { layout layout }
    { level_num integer initial: 0 }
    { location array initial: { 0 0 } }
    { path } ;

: <piece> ( layout -- piece )
    piece new swap >>layout ;

: (piece-blocks) ( piece -- blocks )
    ! rotates the piece
    [ level_num>> ] [ layout>> states>> ] bi nth ;

: wall-blocks ( piece -- blocks )
    [ (piece-blocks) ] [ location>> ] bi [ v+ ] curry map ;

: piece-blocks ( piece -- blocks )
    location>> { } 1sequence ; ! literally just returns the location in a sequence

: set-location ( piece level -- piece )
    ! sets the location of piece to where they are defined in layout
    over layout>> states>> nth first >>location ; 

: is-goal? ( goal-piece location move -- ? )
    ! check if next move is a goal or not
    v+ swap [ level_num>> ] [ layout>> ] bi states>> nth member? ;

: <board-piece> ( -- piece )
    get-board <piece> ;

: <player-piece> ( level -- piece )
    get-player <piece> swap set-location "vocab:sokoban/resources/CharR.png" >>path ;
    

:: <box-piece> ( box-number goal-piece level  -- piece )
    box-number get-box <piece> level set-location "vocab:sokoban/resources/Crate_Yellow.png" >>path dup [ layout>> ] [ location>> ] bi
    goal-piece swap { 0 0 } is-goal?
    [
        COLOR: blue
    ]
    [
        COLOR: orange
    ] if
    >>color drop ;

:: <box-seq> ( goal-piece level -- seq )
    ! get list of boxes on corresponding level
    level get-num-boxes [0..b] [ goal-piece level <box-piece> ] map ;

: (rotate-piece) ( level_num inc n-states -- level_num' )
    [ + ] dip rem ;

: rotate-piece ( piece inc -- piece )
    over layout>> states>> length
    [ (rotate-piece) ] 2curry change-level_num ;

: <goal-piece> ( level -- piece )
    ! rotate goal according to level
    get-goal <piece> swap rotate-piece ;


: move-piece ( piece move -- piece )
    [ v+ ] curry change-location ;
