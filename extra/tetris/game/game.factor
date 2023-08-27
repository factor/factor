! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.

USING: accessors combinators kernel lists math math.functions
sequences system tetris.board tetris.piece ;

IN: tetris.game

TUPLE: tetris
    { board board }
    { pieces }
    { last-update integer initial: 0 }
    { rows integer initial: 0 }
    { score integer initial: 0 }
    { paused? initial: f }
    { running? initial: t } ;

CONSTANT: default-width 10
CONSTANT: default-height 20

: <tetris> ( width height -- tetris )
    dupd <board> swap <piece-llist>
    tetris new swap >>pieces swap >>board ;

: <default-tetris> ( -- tetris )
    default-width default-height <tetris> ;

: <new-tetris> ( old -- new )
    board>> [ width>> ] [ height>> ] bi <tetris> ;

: current-piece ( tetris -- piece ) pieces>> car ;

: next-piece ( tetris -- piece ) pieces>> cdr car ;

: toggle-pause ( tetris -- )
    [ not ] change-paused? drop ;

: level ( tetris -- level )
    rows>> 1 + 10 / ceiling ;

: update-interval ( tetris -- interval )
    level 1 - 60 * 1,000,000,000 swap - ;

: add-block ( tetris block -- )
    over [ board>> ] 2dip current-piece tetromino>> color>> set-block ;

: game-over? ( tetris -- ? )
    [ board>> ] [ next-piece ] bi piece-valid? not ;

: new-current-piece ( tetris -- tetris )
    dup game-over? [
        f >>running?
    ] [
        [ cdr ] change-pieces
    ] if ;

: rows-score ( level n -- score )
    {
        { 0 [ 0 ] }
        { 1 [ 40 ] }
        { 2 [ 100 ] }
        { 3 [ 300 ] }
        { 4 [ 1200 ] }
    } case swap 1 + * ;

: add-score ( tetris n-rows -- tetris )
    over level swap rows-score swap [ + ] change-score ;

: add-rows ( tetris rows -- tetris )
    swap [ + ] change-rows ;

: score-rows ( tetris n -- )
    [ add-score ] keep add-rows drop ;

: lock-piece ( tetris -- )
    [ dup current-piece piece-blocks [ add-block ] with each ]
    [ new-current-piece dup board>> check-rows score-rows ] bi ;

: can-rotate? ( tetris -- ? )
    [ board>> ] [ current-piece clone 1 rotate-piece ] bi piece-valid? ;

: (rotate) ( inc tetris -- )
    dup can-rotate? [ current-piece swap rotate-piece drop ] [ 2drop ] if ;

: rotate-left ( tetris -- ) -1 swap (rotate) ;

: rotate-right ( tetris -- ) 1 swap (rotate) ;

: can-move? ( tetris move -- ? )
    [ drop board>> ] [ [ current-piece clone ] dip move-piece ] 2bi piece-valid? ;

: tetris-move ( tetris move -- ? )
    ! moves the piece if possible, returns whether the piece was moved
    2dup can-move? [
        [ current-piece ] dip move-piece drop t
    ] [
        2drop f
    ] if ;

: move-left ( tetris -- ) { -1 0 } tetris-move drop ;

: move-right ( tetris -- ) { 1 0 } tetris-move drop ;

: move-down ( tetris -- )
    dup { 0 1 } tetris-move [ drop ] [ lock-piece ] if ;

: move-drop ( tetris -- )
    dup { 0 1 } tetris-move [ move-drop ] [ lock-piece ] if ;

: update ( tetris -- )
    nano-count over last-update>> -
    over update-interval > [
        dup move-down
        nano-count >>last-update
    ] when drop ;

: ?update ( tetris -- )
    dup [ paused?>> ] [ running?>> not ] bi or [ drop ] [ update ] if ;
