! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit fry kernel
math sequences sokoban.piece sokoban.tetromino ;
IN: sokoban.board

TUPLE: board
    { width integer }
    { height integer }
    { rows array } ;

: make-rows ( width height -- rows )
    swap '[ _ f <array> ] replicate ;

: <board> ( width height -- board )
    2dup make-rows board boa ;

! A block is simply an array of form { x y } where { 0 0 } is
! the top-left of the sokoban board, and { 9 19 } is the bottom
! right on a 10x20 board.

: board@block ( board block -- n row )
    [ second swap rows>> nth ] keep first swap ;

: set-block ( board block color -- ) -rot board@block set-nth ;

: block ( board block -- color ) board@block nth ;

: block-free? ( board block -- ? ) block not ;

: block-in-bounds? ( board block -- ? )
    [ first swap width>> <iota> bounds-check? ]
    [ second swap height>> <iota> bounds-check? ] 2bi and ;

: location-valid? ( board block -- ? )
    { [ block-in-bounds? ] [ block-free? ] } 2&& ;

: piece-valid? ( board piece -- ? )
    piece-blocks [ location-valid? ] with all? ;
