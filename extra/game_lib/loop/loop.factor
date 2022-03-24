USING: accessors sequences kernel opengl grouping words game.loop delegate namespaces ;

IN: game_lib.loop


SYMBOL: game-loop


: new-game-loop ( interval game-state -- game-loop )
    <game-loop> dup game-loop set ;

: stop-game ( -- )
    game-loop get stop-loop ;