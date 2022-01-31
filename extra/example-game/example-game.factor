USING: gamedev.board sequences accessors ui ui.gadgets ui.gadgets.labels ui.gadgets.status-bar colors.constants ui.pens.solid arrays kernel ;

IN: example-game

: init ( -- )
    ;

TUPLE: game-gadget < gadget cells ;

:: <game-gadget> ( rows cols  -- gadget )
    game-gadget new
        rows cols f make-cells;

:: game-window ( -- )
    [
        5 5 <game-gadget>
        "GAMGINGGNGN" open-status-window
    ] with-ui ;

MAIN: game-window

