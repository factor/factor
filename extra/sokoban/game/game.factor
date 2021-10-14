! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators kernel lists math math.functions math.vectors
sequences system sokoban.board sokoban.piece sokoban.tetromino colors colors.constants ;

IN: sokoban.game

TUPLE: sokoban
    { board }
    { pieces }
    { boxes }
    { goals }
    { last-update integer initial: 0 }
    { rows integer initial: 0 }
    { score integer initial: 0 }
    { level integer initial: 1 }
    { paused? initial: f }
    { running? initial: t } ;

CONSTANT: default-width 9
CONSTANT: default-height 9


: add-wall-block ( sokoban block -- )
    over [ board>> ] 2dip default-width <board-piece> swap level>> rotate-piece tetromino>> colour>> set-block ;

: add-walls ( sokoban -- ) 
    dup default-width <board-piece> swap level>> rotate-piece piece-blocks [ add-wall-block ] with each ;

: <sokoban> ( width height -- sokoban )
    dupd dupd dupd <board> swap <player-llist>
    sokoban new swap >>pieces swap >>board 
    swap <box-llist> >>boxes
    swap <goal-llist> >>goals
    dup add-walls ;

: <default-sokoban> ( -- sokoban )
    default-width default-height <sokoban> ;

: <new-sokoban> ( old -- new )
    board>> [ width>> ] [ height>> ] bi <sokoban> ;

: current-piece ( sokoban -- piece ) pieces>> car ;

: current-box ( sokoban -- box ) boxes>> car ;

: current-goal ( sokoban -- box ) goals>> car ;

: next-piece ( sokoban -- piece ) pieces>> cdr car ;

: toggle-pause ( sokoban -- )
    [ not ] change-paused? drop ;

: level ( sokoban -- level )
    rows>> 1 + 10 / ceiling ;

: update-interval ( sokoban -- interval )
    level 1 - 60 * 1,000,000,000 swap - ;

: add-block ( sokoban block -- )
    over [ board>> ] 2dip current-piece tetromino>> colour>> set-block ;

: game-over? ( sokoban -- ? )
    [ board>> ] [ next-piece ] bi piece-valid? not ;

: new-current-piece ( sokoban -- sokoban )
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

: add-score ( sokoban n-rows -- sokoban )
    over level swap rows-score swap [ + ] change-score ;

: add-rows ( sokoban rows -- sokoban )
    swap [ + ] change-rows ;

: score-rows ( sokoban n -- )
    [ add-score ] keep add-rows drop ;

: lock-piece ( sokoban -- )
    [ dup current-piece piece-blocks [ add-block ] with each ]
    [ new-current-piece dup board>> check-rows score-rows ] bi ;

: can-rotate? ( sokoban -- ? )
    [ board>> ] [ current-piece clone 1 rotate-piece ] bi piece-valid? ;

: (rotate) ( inc sokoban -- )
    dup can-rotate? [ current-piece swap rotate-piece drop ] [ 2drop ] if ;

: rotate-left ( sokoban -- ) -1 swap (rotate) ;

: rotate-right ( sokoban -- ) 1 swap (rotate) ;

: can-player-move? ( sokoban move -- ? )
    [ drop board>> ] [ [ current-piece clone ] dip move-piece ] 2bi piece-valid? ;

: can-box-move? ( sokoban move -- ? )
    [ drop board>> ] [ [ current-box clone ] dip move-piece ] 2bi piece-valid? ;

: is-box? ( sokoban move -- ? )
    dupd [ current-piece ] dip swap location>> v+ [ current-box ] dip swap location>> = ;

: is-goal? ( sokoban move -- ? )
    dupd [ current-box ] dip swap location>> v+ [ current-goal ] dip swap location>> = ;

: sokoban-move ( sokoban move -- ? )
    2dup can-player-move? [
        2dup is-box? [
            2dup can-box-move? [
                2dup is-goal? [
                    2dup [ current-piece ] dip move-piece drop 
                    [ current-box ] dip move-piece tetromino>> COLOR: blue >>colour drop t
                ] [
                ! next location is a box and box can be moved
                    2dup [ current-piece ] dip move-piece drop 
                    [ current-box ] dip move-piece tetromino>> COLOR: orange >>colour drop t
                ] if
            ] [
                ! next location is a box and box cannot be moved
                2drop f
            ] if
        ]
        [   ! next location is not a box
            soko current-piece mov move-piece drop t
        ] if 
    ]
    [   ! player cannot move
        f
    ] if ;


: move-left ( sokoban -- ) { -1 0 } sokoban-move drop ;

: move-right ( sokoban -- ) { 1 0 } sokoban-move drop ;

: move-down ( sokoban -- ) { 0 1 } sokoban-move drop ;

: move-up ( sokoban -- ) { 0 -1 } sokoban-move drop ;

! : move-drop ( sokoban -- )
    ! dup { 0 1 } sokoban-move [ move-drop ] [ lock-piece ] if ;

: update ( sokoban -- )
    nano-count over last-update>> -
    over update-interval > [
        ! dup move-down
        nano-count >>last-update
    ] when drop ;

: ?update ( sokoban -- )
    dup [ paused?>> ] [ running?>> not ] bi or [ drop ] [ update ] if ;
