USING: colors jamshred.game jamshred.oint jamshred.tunnel kernel
math math.constants sequences ;
IN: jamshred.player

TUPLE: player name tunnel nearest-segment ;

: <player> ( name -- player )
    f f player construct-boa
    F{ 0 0 5 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } <oint> over set-delegate ;

: turn-player ( player x-radians y-radians -- )
    >r over r> left-pivot up-pivot ;

: to-tunnel-start ( player -- )
    dup player-tunnel first dup oint-location pick set-oint-location
    swap set-player-nearest-segment ;

: play-in-tunnel ( player segments -- )
    over set-player-tunnel to-tunnel-start ;

: update-nearest-segment ( player -- )
    dup player-tunnel over dup player-nearest-segment nearest-segment
    swap set-player-nearest-segment ;

: max-speed ( -- speed )
    0.3 ;

: player-speed ( player -- speed )
    dup player-nearest-segment fraction-from-wall sq max-speed * ;

: move-player ( player -- )
    dup player-speed over go-forward update-nearest-segment ;

: update-player ( player -- )
    dup move-player player-nearest-segment
    white swap set-segment-color ;
