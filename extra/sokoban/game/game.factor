! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators kernel lists math math.functions math.vectors
sequences system sokoban.board sokoban.piece sokoban.tetromino colors 
colors.constants namespaces locals ;

IN: sokoban.game

TUPLE: sokoban
    { board }
    { player }
    { boxes }
    { goals }
    { last-update integer initial: 0 }
    { level integer initial: 0 }
    { paused? initial: f }
    { running? initial: t } ;

: add-wall-block ( sokoban block -- )
    over [ board>> ] 2dip <board-piece> swap level>> rotate-piece tetromino>> color>> set-block ;

: add-walls ( sokoban -- ) 
    dup <board-piece> swap level>> rotate-piece wall-blocks [ add-wall-block ] with each ;

:: <sokoban> ( lev w h -- sokoban )
    ! make components
    w h <board> :> board
    lev <player-piece> :> player
    <goal-piece> :> goals

    ! put components into sokoban instance
    sokoban new :> soko
    soko player >>player
    lev >>level
    board >>board
    goals >>goals
    goals lev <box-seq> >>boxes
    soko add-walls ; ! draw walls
    

: <default-sokoban> ( -- sokoban )
    ! Level 0 sokoban
    0 8 9 <sokoban> ;

: toggle-pause ( sokoban -- )
    [ not ] change-paused? drop ;

: update-interval ( sokoban -- interval )
    level>> 1 - 60 * 1,000,000,000 swap - ;

: add-block ( sokoban block -- )
    over [ board>> ] 2dip player>> tetromino>> color>> set-block ;

: can-rotate? ( sokoban -- ? )
    [ board>> ] [ player>> clone 1 rotate-piece ] bi piece-valid? ;

: (rotate) ( inc sokoban -- )
    dup can-rotate? [ player>> swap rotate-piece drop ] [ 2drop ] if ;

: rotate-left ( sokoban -- ) -1 swap (rotate) ;

: rotate-right ( sokoban -- ) 1 swap (rotate) ;

: can-player-move? ( sokoban move -- ? )
    [ drop board>> ] [ [ player>> clone ] dip move-piece ] 2bi piece-valid? ;

:: get-adj-box ( soko piece mov -- box ) 
    ! If the input piece (either a player or another box) has a box at its move location,
    ! return the box at the move location. Otherwise, return false
    piece location>> :> player_loc
    player_loc mov v+ :> next_loc
    soko boxes>> :> box_list
    box_list [ location>> next_loc = ] find swap drop ;

:: can-box-move? ( soko box mov -- ? )
    soko box mov get-adj-box :> box2move ! Checks if input box has a box at its move location
    box2move
    [   ! If there is another box at the move location, the current box is unable to move
        f
    ]
    [   ! Otherwise, we check if there is a wall blocking the box
        soko board>> box clone mov move-piece piece-valid?
    ] if ;

:: sokoban-move ( soko mov -- ? )
    ! Collision logic -- checks if player can move and moves the player accordingly
    ! TODO: make function more readable by using cond (?)
    soko mov can-player-move?
    [   ! Player can move
        soko dup player>> mov get-adj-box :> box2move
        box2move
        [   ! Next location of player is a box
            soko box2move mov can-box-move?
            [   ! Next location of player is a box and box is able to move
                soko goals>> box2move location>> mov is-goal?
                [   ! Next location of box is a goal point
                    soko player>> mov move-piece drop
                    box2move mov move-piece
                    tetromino>> COLOR: blue >>color drop t ! change color once box is on goal
                ]
                [   ! Next location of box is a free space
                    soko player>> mov move-piece drop
                    box2move mov move-piece
                    tetromino>> COLOR: orange >>color drop t
                ] if
            ]
            [   ! Next location of player is a box but box cannot move
                f
            ] if
        ]
        [   ! Next location of player is a free space, move the player onto the free space
            soko player>> mov move-piece drop t
        ] if 
    ]
    [   ! Player cannot move
        f
    ] if ;


: move-left ( sokoban -- ) { -1 0 } sokoban-move drop ;

: move-right ( sokoban -- ) { 1 0 } sokoban-move drop ;

: move-down ( sokoban -- ) { 0 1 } sokoban-move drop ;

: move-up ( sokoban -- ) { 0 -1 } sokoban-move drop ;

: update-level? ( sokoban -- ? )
    ! Get color color of each box
    boxes>> [ tetromino>> ] map [ color>> ] map 
    ! All boxes are on correct spots if there are no orange boxes left and level should be updated
    [ COLOR: orange ] first swap member? not ;

