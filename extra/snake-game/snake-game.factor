! Copyright (C) 2015 Sankaranarayanan Viswanathan
! See https://factorcode.org/license.txt for BSD license.
USING: accessors sets snake-game.ui ui ui.gadgets.status-bar
ui.gadgets.worlds ;
IN: snake-game

: <snake-world-attributes> ( -- world-attributes )
    <world-attributes> "Snake Game" >>title
    [
        { maximize-button resize-handles } without
    ] change-window-controls ;

: play-snake-game ( -- )
    [
        <snake-gadget>
        <snake-world-attributes>
        open-status-window
    ] with-ui ;

MAIN: play-snake-game
