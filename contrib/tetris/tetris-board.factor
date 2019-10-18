! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays tetris-piece math ;
IN: tetris-board

TUPLE: board width height rows ;

: make-rows ( width height -- rows )
    [ drop f <array> ] map-with ;

C: board ( width height -- board )
    >r 2dup make-rows r>
    [ set-board-rows ] keep
    [ set-board-height ] keep
    [ set-board-width ] keep ;

#! A block is simply an array of form { x y } where { 0 0 } is the top-left of
#! the tetris board, and { 9 19 } is the bottom right on a 10x20 board.

: board@block ( board block -- n row )
    [ second swap board-rows nth ] keep first swap ;

: board-set-block ( board block colour -- ) -rot board@block set-nth ;
  
: board-block ( board block -- colour ) board@block nth ;

: block-free? ( board block -- ? ) board-block not ;

: block-in-bounds? ( board block -- ? )
    [ first swap board-width bounds-check? ] 2keep
    second swap board-height bounds-check? and ;

: location-valid? ( board block -- ? )
    2dup block-in-bounds? [ block-free? ] [ 2drop f ] if ;

: piece-valid? ( board piece -- ? )
    piece-blocks [ location-valid? ] all-with? ;

: row-not-full? ( row -- ? ) f swap member? ;

: add-row ( board -- )
    dup board-rows over board-width f <array>
    add* swap set-board-rows ;

: top-up-rows ( board -- )
    dup board-height over board-rows length = [
	drop
    ] [
	dup add-row top-up-rows
    ] if ;

: remove-full-rows ( board -- )
    dup board-rows [ row-not-full? ] subset swap set-board-rows ;

: check-rows ( board -- n )
    #! remove full rows, then add blank ones at the top, returning the number
    #! of rows removed (and added)
    dup remove-full-rows dup board-height over board-rows length - >r top-up-rows r> ;

