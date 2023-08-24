! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit kernel
math sequences tetris.piece ;
IN: tetris.board

TUPLE: board
    { width integer }
    { height integer }
    { rows array } ;

: make-rows ( width height -- rows )
    swap '[ _ f <array> ] replicate ;

: <board> ( width height -- board )
    2dup make-rows board boa ;

! A block is simply an array of form { x y } where { 0 0 } is
! the top-left of the tetris board, and { 9 19 } is the bottom
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

: row-not-full? ( row -- ? ) f swap member? ;

: add-row ( board -- board )
    dup rows>> over width>> f <array> prefix >>rows ;

: top-up-rows ( board -- )
    dup height>> over rows>> length = [
        drop
    ] [
        add-row top-up-rows
    ] if ;

: remove-full-rows ( board -- board )
    [ [ row-not-full? ] filter ] change-rows ;

: check-rows ( board -- n )
    ! remove full rows, then add blank ones at the top,
    ! returning the number of rows removed (and added)
    remove-full-rows dup height>> over rows>> length - swap top-up-rows ;
