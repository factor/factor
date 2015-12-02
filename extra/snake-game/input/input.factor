! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs sets snake-game.constants ;
IN: snake-game.input

: key-action ( key -- action )
    H{
        { "RIGHT"  :right }
        { "LEFT"   :left }
        { "UP"     :up }
        { "DOWN"   :down }
    } at ;

: quit-key? ( key -- ? )
    HS{ "ESC" "q" "Q" } in? ;

: pause-key? ( key -- ? )
    HS{ " " "SPACE" "p" "P" } in? ;

: new-game-key? ( key -- ? )
    HS{ "ENTER" "RET" "n" "N" } in? ;
