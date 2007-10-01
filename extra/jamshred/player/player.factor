USING: colors jamshred.game jamshred.oint jamshred.tunnel kernel
math.constants sequences ;
IN: jamshred.player

TUPLE: player name speed last-segment ;

: <player> ( name -- player )
    1 f player construct-boa
    { 0 0 5 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint> over set-delegate ;

: turn-player ( player x-radians y-radians -- )
    >r over r> left-pivot up-pivot ;

: play-in-tunnel ( player tunnel -- )
    tunnel-segments first dup oint-location pick set-oint-location
    swap set-player-last-segment ;

: player-nearest-segment ( tunnel player -- segment )
    [
        dup player-last-segment nearest-segment
    ] keep dupd set-player-last-segment ;

: update-player ( tunnel player -- )
    0.1 over go-forward player-nearest-segment white swap set-segment-color ;

