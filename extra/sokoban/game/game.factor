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

SYMBOL: default-width
8 default-width set-global

SYMBOL: default-height
9 default-height set-global


: add-wall-block ( sokoban block -- )
    over [ board>> ] 2dip default-width get <board-piece> swap level>> rotate-piece tetromino>> color>> set-block ;

: add-walls ( sokoban -- ) 
    dup default-width get <board-piece> swap level>> rotate-piece wall-blocks [ add-wall-block ] with each ;

! : <sokoban> ( width height -- sokoban )
!     dupd dupd dupd <board> swap <player-llist>
!     sokoban new  1 >>level swap >>pieces swap >>board 
!     swap <goal-piece> >>goals
!     swap dupd [ goals>> ] dip <box-seq> >>boxes
!     dup add-walls ;

:: <sokoban> ( lev w h -- sokoban )
    ! make components
    w h <board> :> board
    h <player-llist> :> player
    h <goal-piece> :> goals
    ! put components into sokoban instance
    sokoban new :> soko
    soko player >>pieces
    lev >>level
    board >>board
    goals >>goals

    goals h lev <box-seq> >>boxes
    soko add-walls ;
    

: <default-sokoban> ( -- sokoban )
    0 default-width get default-height get <sokoban> ;

: <new-sokoban> ( old level -- new )
    swap board>> [ width>> ] [ height>> ] bi <sokoban> ;

: current-piece ( sokoban -- piece ) pieces>> car ;

: current-goal ( sokoban -- box ) goals>> car ;

: toggle-pause ( sokoban -- )
    [ not ] change-paused? drop ;

: level ( sokoban -- level )
    level>> ;

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

:: get-adj-box ( soko piece mov -- box ) ! If the next spot has a box, return the box. Otherwise, return f.
    piece location>> :> player_loc
    player_loc mov v+ :> next_loc
    soko boxes>> :> box_list
    box_list [ location>> next_loc = ] find swap drop ;

:: can-box-move? ( soko box mov -- ? )
    ! takes in a box and uses get-adj-box to check if there is a box next to the input box
    soko box mov get-adj-box :> box2move
    box2move
    [   ! yes box next to box
        f
    ]
    [   ! no box next to box (can first box move)
        soko board>> box clone mov move-piece piece-valid?
    ] if ;

:: sokoban-move ( soko mov -- ? )
    soko mov can-player-move?
    [   soko dup current-piece mov get-adj-box :> box2move
        box2move
        [   soko box2move mov can-box-move?
            [   soko goals>> box2move location>> mov is-goal?
                [   ! box can be moved onto goal point
                    soko current-piece mov move-piece drop
                    box2move mov move-piece
                    tetromino>> COLOR: blue >>color drop t ! change color once box is on goal
                ]
                [   ! box can be moved onto free tile
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

! :: update-level ( soko -- sokoban )
!     ! 
!     soko update-level? 
!     [
!         soko level>> 1 + :> new_level ! increment level by one
!         soko new_level >>level
!         ! gets and sets height and width of new board at next level
!         new_level component get first states>> nth :> new_board
!         new_board [ first ] map :> x_vals
!         new_board [ second ] map :> y_vals
!         x_vals supremum :> x_max
!         y_vals supremum :> y_max
!         y_max default-height set
!         x_max default-width set
!         soko board>> x_max >>width drop
!         soko board>> y_max >>height drop
!         soko add-walls ! needs to be called again to set walls wrt current level
!         <new-sokoban> ! not useful if we want to change size of board
!     ]
!     [ soko ] if ;
! TODO: reimplement changing height and width with new update implementation

