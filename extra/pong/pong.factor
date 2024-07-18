USING: accessors arrays calendar colors
combinators.short-circuit fonts kernel literals math math.order
math.vectors namespaces opengl random ranges sequences timers ui
ui.commands ui.gadgets ui.gadgets.worlds ui.gestures
ui.pens.solid ui.render ui.text ;

IN: pong

CONSTANT: BOUNCE 6/5
CONSTANT: MAX-SPEED 6
CONSTANT: BALL-SIZE 10
CONSTANT: BALL-DIM ${ BALL-SIZE BALL-SIZE }
CONSTANT: PADDLE-SIZE 80
CONSTANT: PADDLE-DIM ${ PADDLE-SIZE 10 }
CONSTANT: FONT $[
    monospace-font
        t >>bold?
        COLOR: red >>foreground
        COLOR: gray95 >>background
    ]

TUPLE: ball pos vel ;

TUPLE: pong-gadget < gadget timer ball player computer game-over? ;

: initial-state ( gadget -- gadget )
    T{ ball { pos { 50 50 } } { vel { 3 4 } } } clone >>ball
    200 >>player
    200 >>computer
    f >>game-over? ;

DEFER: on-tick

: <pong-gadget> ( -- gadget )
    pong-gadget new initial-state
        COLOR: gray95 <solid> >>interior
        dup '[ _ on-tick ] f 16 milliseconds <timer> >>timer ;

M: pong-gadget pref-dim* drop { 400 400 } ;

M: pong-gadget ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

M:: pong-gadget draw-gadget* ( PONG -- )
    COLOR: gray80 gl-color
    15 390 20 <range> [
        197 2array { 10 6 } gl-fill-rect
    ] each

    COLOR: black gl-color
    { 0 0 } { 10 400 } gl-fill-rect
    { 390 0 } { 10 400 } gl-fill-rect

    PONG computer>> 0 2array PADDLE-DIM gl-fill-rect
    PONG player>> 390 2array PADDLE-DIM gl-fill-rect
    PONG ball>> pos>> BALL-DIM gl-fill-rect

    PONG game-over?>> [
        FONT 48 >>size
        PONG ball>> pos>> second 200 <
        "YOU WIN!" "YOU LOSE!" ?
        [ text-width 390 swap - 2 / 100 2array ]
        [ '[ _ _ draw-text ] with-translation ] 2bi
    ] [
        PONG timer>> thread>> [
            FONT 24 >>size
            { "    N - New Game" "SPACE - Pause" }
            [ text-width 390 swap - 2 / 100 2array ]
            [ '[ _ _ draw-text ] with-translation ] 2bi
        ] unless
    ] if ;

:: move-player ( GADGET -- )
    hand-loc get first PADDLE-SIZE 2 / -
    10 390 PADDLE-SIZE - clamp GADGET player<< ;

:: move-ball ( GADGET -- )
    GADGET ball>> :> BALL

    ! minimum movement to hit wall or paddle
    BALL vel>> first dup 0 > 380 10 ?
    BALL pos>> first - swap / 1 min
    BALL vel>> second dup 0 > 380 10 ?
    BALL pos>> second - swap / 1 min min :> movement

    movement 0 > [ movement throw ] unless
    BALL pos>> BALL vel>> movement v*n v+ BALL pos<< ;

: move-computer-by ( GADGET N -- )
    '[ _ + 10 390 PADDLE-SIZE - clamp ] change-computer drop ;

:: move-computer ( GADGET -- )
    GADGET ball>> pos>> first :> X
    GADGET computer>> PADDLE-SIZE 2/ + :> COMPUTER

    ! ball on the left
    X BALL-SIZE + COMPUTER - dup 0 < [
        >integer -10 max 0 [a..b] random
        GADGET swap move-computer-by
    ] [ drop ] if

    ! ball on the right
    X COMPUTER - dup 0 > [
        >integer 10 min [0..b] random
        GADGET swap move-computer-by
    ] [ drop ] if ;

:: bounce-off-paddle ( BALL PADDLE -- )
    BALL pos>> first BALL-SIZE 2 / +
    PADDLE PADDLE-SIZE 2 / + - 1/4 *
    BALL vel>> second neg BOUNCE * MAX-SPEED min 2array
    BALL vel<< ;

:: ?bounce-off-paddle ( BALL GADGET PADDLE -- )
    BALL pos>> first dup BALL-SIZE +
    PADDLE dup PADDLE-SIZE + '[ _ _ between? ] either? [
        BALL PADDLE bounce-off-paddle
    ] [
        GADGET t >>game-over? timer>> stop-timer
    ] if ;

: bounce-off-wall ( BALL -- )
    0 swap vel>> [ neg ] change-nth ;

:: on-tick ( GADGET -- )
    GADGET move-player
    GADGET move-ball
    GADGET move-computer

    GADGET ball>>     :> BALL
    GADGET player>>   :> PLAYER
    GADGET computer>> :> COMPUTER

    BALL pos>> first2 :> ( X Y )
    BALL vel>> first2 :> ( DX DY )

    { [ DY 0 > ] [ Y 380 >= ] } 0&&
    [ BALL GADGET PLAYER ?bounce-off-paddle ] when

    { [ DY 0 < ] [ Y 10 <= ] } 0&&
    [ BALL GADGET COMPUTER ?bounce-off-paddle ] when

    X { [ 10 <= ] [ 380 >= ] } 1||
    [ BALL bounce-off-wall ] when

    GADGET relayout-1 ;

: com-new-game ( gadget -- )
    initial-state timer>> restart-timer ;

: com-pause ( gadget -- )
    dup game-over?>> [
        dup timer>> dup thread>>
        [ stop-timer ] [ restart-timer ] if
    ] unless relayout-1 ;

pong-gadget "gestures" f {
    { T{ key-down { sym "n" } } com-new-game }
    { T{ key-down { sym " " } } com-pause }
} define-command-map

MAIN-WINDOW: pong-window {
    { title "PONG" }
    { window-controls
        { normal-title-bar close-button minimize-button } }
    } <pong-gadget> >>gadgets ;
