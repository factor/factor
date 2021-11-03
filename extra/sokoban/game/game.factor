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
    swap <goal-piece> >>goals
    swap dupd [ goals>> ] dip <box-seq> >>boxes
    dup add-walls ;

: <default-sokoban> ( -- sokoban )
    default-width default-height <sokoban> ;

: <new-sokoban> ( old -- new )
    board>> [ width>> ] [ height>> ] bi <sokoban> ;

: current-piece ( sokoban -- piece ) pieces>> car ;

: current-goal ( sokoban -- box ) goals>> car ;

: toggle-pause ( sokoban -- )
    [ not ] change-paused? drop ;

: level ( sokoban -- level )
    rows>> 1 + 10 / ceiling ;

: update-interval ( sokoban -- interval )
    level 1 - 60 * 1,000,000,000 swap - ;

: add-block ( sokoban block -- )
    over [ board>> ] 2dip current-piece tetromino>> color>> set-block ;

: can-rotate? ( sokoban -- ? )
    [ board>> ] [ current-piece clone 1 rotate-piece ] bi piece-valid? ;

: (rotate) ( inc sokoban -- )
    dup can-rotate? [ current-piece swap rotate-piece drop ] [ 2drop ] if ;

: rotate-left ( sokoban -- ) -1 swap (rotate) ;

: rotate-right ( sokoban -- ) 1 swap (rotate) ;

: can-player-move? ( sokoban move -- ? )
    [ drop board>> ] [ [ current-piece clone ] dip move-piece ] 2bi piece-valid? ;

:: get-adj-box ( soko piece mov -- box ) ! returns the box if the next spot has a box, and ??? otherwise
    piece location>> :> player_loc
    player_loc mov v+ :> next_loc
    soko boxes>> :> box_list
    box_list [ location>> next_loc = ] find swap drop ;

:: can-box-move? ( soko box mov -- ? )
    soko box mov get-adj-box :> box2move
    box2move
    [ 
        ! yes box next to box
        f
    ]
    [
        ! no box next to box (can first box move)
        soko board>> box clone mov move-piece piece-valid?
    ] if ;

:: sokoban-move ( soko mov -- ? )
    soko mov can-player-move?
    [   soko dup current-piece mov get-adj-box :> box2move
        box2move
        [   soko box2move mov can-box-move?
            [   soko goals>> box2move location>> mov is-goal?
                [   ! next location is a box and box can be moved to a goal point
                    soko current-piece mov move-piece drop
                    box2move mov move-piece
                    tetromino>> COLOR: blue >>color drop t
                ]
                [   ! next location is a box and box can be moved to a non-goal point
                    soko current-piece mov move-piece drop
                    box2move mov move-piece
                    tetromino>> COLOR: orange >>color drop t
                ] if
            ]
            [   ! next location is a box or wall and box cannot be moved
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

: update-level? ( sokoban -- ? )
    ! get color item of each box
    boxes>> [ tetromino>> ] map [ color>> ] map 
    ! update if there are no orange pieces left
    [ COLOR: orange ] first swap member? not ;

: update-level ( sokoban -- sokoban )
    ! 
    dup update-level? 
    [
        1 >>level
        dup add-walls ! needs to be called again to set walls wrt current level
        <new-sokoban> ! not useful if we want to change size of board
    ] [
        
    ] if ;

: update ( sokoban -- )
    update-level
    nano-count over last-update>> -
    over update-interval > [
        ! dup move-down
        nano-count >>last-update
    ] when drop ;

: ?update ( sokoban -- )
    dup [ paused?>> ] [ running?>> not ] bi or [ drop ] [ update ] if ;
