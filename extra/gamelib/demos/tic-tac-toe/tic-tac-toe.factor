USING: kernel namespaces accessors fonts literals ui.text
sequences math gamelib.ui gamelib.board colors ui.gestures
ui.gadgets opengl gamelib.loop game.loop ;

IN: gamelib.demos.tic-tac-toe

CONSTANT: X "vocab:gamelib/demos/tic-tac-toe/resources/X.png"
CONSTANT: O "vocab:gamelib/demos/tic-tac-toe/resources/O.png"

SYMBOL: player
X player set-global 

: background ( gadget -- gadget )
    COLOR: pink set-background-color
    X { 80 80 } { 30 30 } draw-image
    X { 10 10 } { 40 40 } draw-image ;

: foreground ( gadget -- gadget ) 
    COLOR: black { 123 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 256 0 } { 10 400 } draw-filled-rectangle
    COLOR: black { 0 123 } { 400 10 } draw-filled-rectangle
    COLOR: black { 0 256 } { 400 10 } draw-filled-rectangle ;

: board ( gadget -- gadget )
    3 3 make-board { } 1sequence
    add-board ; 

: set-player ( -- )
    player get-global X =
    [ O player set-global ]
    [ X player set-global ]
    if ;

:: set-board ( board cell-pos cell -- )
    board cell-pos is-cell-empty?
    [ 
        board cell-pos cell add-to-cell drop
        set-player
    ] when ;

:: on-click ( -- quot )
    [ dup board>> first swap hand-rel-cell player get-global set-board ] ;

:: row-win ( board -- ? )
    ! Returns true if either X or O has a row win
    ! For each row, check if every element in specified row equals X, returning true if any row meets the condition
    { 0 1 2 } [ { $ X } swap board swap get-row all-equal-value? ] any?
    ! Same check but with O
    { 0 1 2 } [ { $ O } swap board swap get-row all-equal-value? ] any? or ;

:: col-win ( board -- ? )
    ! Same as row win except checks column wins
    { 0 1 2 } [ { $ X } swap board swap get-col all-equal-value? ] any?
    { 0 1 2 } [ { $ O } swap board swap get-col all-equal-value? ] any? or ;

:: diag-win ( board -- ? )
    ! Same as row win except checks diagonal wins
    { $ X } board { { 0 0 } { 1 1 } { 2 2 } } get-cells all-equal-value?
    { $ X } board { { 2 0 } { 1 1 } { 0 2 } } get-cells all-equal-value? or
    { $ O } board { { 0 0 } { 1 1 } { 2 2 } } get-cells all-equal-value? or
    { $ O } board { { 2 0 } { 1 1 } { 0 2 } } get-cells all-equal-value? or ;

:: check-win ( board -- ? )
    ! Returns true if any win condition is met
    board row-win board col-win or board diag-win or ;

: game-logic ( gadget -- gadget )
    T{ button-down { # 1 } } on-click new-gesture 
    T{ button-down { # 3 } } on-click new-gesture ;

TUPLE: game-state gadget ;


: game-over ( gadget -- gadget )
    [ { 75 75 } [ monospace-font t >>bold? 50 >>size COLOR: red >>foreground "GAME OVER" draw-text ] with-translation ] draw-quote ;

:: <game-state> ( gadget -- gadget game-state )
    gadget 
    game-state new 
    gadget >>gadget ;


: create-loop ( game-state -- )
    1000 swap new-game-loop start-loop ;


: tick-update ( game-state -- )
    dup gadget>> board>> first check-win 
    [ gadget>> game-over relayout-1 stop-game ] 
    [ gadget>> relayout-1 ] if ;


M: game-state tick* tick-update ;

M: game-state draw* drop drop ;


: main ( -- )
    { 400 400 } init-board-gadget
    background board foreground
    game-logic
    <game-state> create-loop 
    display ; 

MAIN: main
