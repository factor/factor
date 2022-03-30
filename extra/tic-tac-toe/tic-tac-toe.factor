USING: kernel namespaces accessors sequences math game_lib.ui game_lib.board colors ui.gestures ui.gadgets ;

IN: tic-tac-toe

CONSTANT: X "vocab:tic-tac-toe/resources/X.png"
CONSTANT: O "vocab:tic-tac-toe/resources/O.png"

SYMBOL: player
X player set-global 

: background ( gadget -- gadget )
    COLOR: pink set-background-color ;

: foreground ( gadget -- gadget ) 
    COLOR: black { 123 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 256 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 0 123 } { 400 10 } draw-filled-rectangle
    COLOR: black { 0 256 } { 400 10 } draw-filled-rectangle ;

: board ( gadget -- gadget )
    3 3 make-board { } 1sequence
    
    create-board ; 

: set-player ( -- )
    player get-global X =
    [ O player set-global ]
    [ X player set-global ]
    if ;

:: set-board ( board cell-pos cell -- )
    board cell-pos is-cell-empty?
    [ 
        board cell-pos cell set-cell drop
        set-player
    ] when ;

:: on-click ( -- quot )
    [ dup dup board>> first swap hand-rel-cell player get-global set-board relayout-1 ] ;

:: row-win ( board -- ? )
    ! Returns true if either X or O has a row win
    ! For each row, check if every element in specified row equals X, returning true if any row meets the condition
    { 0 1 2 } [ X swap board swap get-row all-equal-value? ] any?
    ! Same check but with O
    { 0 1 2 } [ O swap board swap get-row all-equal-value? ] any? or ;

:: col-win ( board -- ? )
    ! Same as row win except checks column wins
    { 0 1 2 } [ X swap board swap get-col all-equal-value? ] any?
    { 0 1 2 } [ O swap board swap get-col all-equal-value? ] any? or ;

:: diag-win ( board -- ? )
    ! Same as row win except checks diagonal wins
    X board { { 0 0 } { 1 1 } { 2 2 } } get-cells all-equal-value?
    X board { { 2 0 } { 1 1 } { 0 2 } } get-cells all-equal-value? or
    O board { { 0 0 } { 1 1 } { 2 2 } } get-cells all-equal-value? or
    O board { { 2 0 } { 1 1 } { 0 2 } } get-cells all-equal-value? or ;

:: check-win ( board -- ? )
    ! Returns true if any win condition is met
    board row-win board col-win or board diag-win or ;

: game-logic ( gadget -- gadget )
    T{ button-down { # 1 } } on-click new-gesture 
    T{ button-down { # 3 } } on-click new-gesture 
    ! set rules
    ;

! : game-over (  )
    ! 

! : tick-update ( not sure what should go here )
    ! check rules and call game over function when rules are not met

! : draw-update ( ??? )
    ! redraws gadget

! : game-loop ( gadget -- gadget )
    ! 100 init-loop (initialize and start the loop given a tick interval?)
    ! tick-update draw-update (define what happens in loop -- pass in game loop?)

: main ( -- )
    { 400 400 } init-window
    background board foreground
    game-logic
    ! game-loop 
    display ; 

MAIN: main