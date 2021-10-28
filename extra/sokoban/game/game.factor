! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators kernel lists math math.functions math.vectors
sequences system sokoban.board sokoban.piece sokoban.tetromino colors 
colors.constants namespaces locals ;

IN: sokoban.game

TUPLE: sokoban
    { board }
    { pieces }
    { boxes }
    { goals }
    { last-update integer initial: 0 }
    { rows integer initial: 0 }
    { score integer initial: 0 }
    { level integer initial: 0 }
    { paused? initial: f }
    { running? initial: t } ;

CONSTANT: default-width 8
CONSTANT: default-height 9


: add-wall-block ( sokoban block -- )
    over [ board>> ] 2dip default-width <board-piece> swap level>> rotate-piece tetromino>> color>> set-block ;

: add-walls ( sokoban -- ) 
    dup default-width <board-piece> swap level>> rotate-piece wall-blocks [ add-wall-block ] with each ;

: <sokoban> ( width height -- sokoban )
    dupd dupd dupd <board> swap <player-llist>
    sokoban new swap >>pieces swap >>board 
    swap <box-seq> >>boxes
    swap <goal-llist> >>goals
    dup add-walls ;

: <default-sokoban> ( -- sokoban )
    default-width default-height <sokoban> ;

: <new-sokoban> ( old -- new )
    board>> [ width>> ] [ height>> ] bi <sokoban> ;

: current-piece ( sokoban -- piece ) pieces>> car ;

: current-box ( sokoban -- box ) boxes>> first ;

: current-goal ( sokoban -- box ) goals>> car ;

: next-piece ( sokoban -- piece ) pieces>> cdr car ;

: toggle-pause ( sokoban -- )
    [ not ] change-paused? drop ;

: level ( sokoban -- level )
    rows>> 1 + 10 / ceiling ;

: update-interval ( sokoban -- interval )
    level 1 - 60 * 1,000,000,000 swap - ;

: add-block ( sokoban block -- )
    over [ board>> ] 2dip current-piece tetromino>> color>> set-block ;

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
    [ dup current-piece wall-blocks [ add-block ] with each ]
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

:: is-box? ( soko mov -- ? )
    soko current-piece location>> :> playerLoc
    soko current-box location>> :> boxLoc
    playerLoc mov v+ :> playerNextLoc
    playerNextLoc boxLoc = ;

:: sokoban-move ( soko mov -- ? )
    soko mov can-player-move?
    [   soko mov is-box?
        [   soko mov can-box-move?
            [   soko current-box location>> mov is-goal?
                [   ! next location is a box and box can be moved to a goal point
                    soko current-piece mov move-piece drop
                    soko current-box mov move-piece
                    tetromino>> COLOR: blue >>color drop t
                ]
                [   ! next location is a box and box can be moved to a non-goal point
                    soko current-piece mov move-piece drop
                    soko current-box mov move-piece
                    tetromino>> COLOR: orange >>color drop t
                ] if
            ]
            [   ! next location is a box and box cannot be moved
                f
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
