USING: jamshred.game jamshred.oint jamshred.tunnel kernel
math.constants ;
IN: jamshred.player

TUPLE: player name speed last-segment ;

: <player> ( name -- player )
    1 f player construct-boa
    { 0 0 5 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint> over set-delegate ;

: update-player ( player -- )
    0.1 swap go-forward ;

: turn-player ( player x-radians y-radians -- )
    >r over r> left-pivot up-pivot ;

: player-nearest-segment ( tunnel player -- segment )
    [
        dup player-last-segment nearest-segment
    ] keep dupd set-player-last-segment ;
