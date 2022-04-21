USING: accessors sequences kernel opengl grouping words game.loop delegate namespaces ;

IN: game_lib.loop


SYMBOL: game-loop


: new-game-loop ( interval game-state -- game-loop )
    <game-loop> dup game-loop set-global ;

:: stop-game ( -- )
    game-loop get-global :> loop
    loop
    [ loop stop-loop ] when ;