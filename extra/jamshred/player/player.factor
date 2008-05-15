! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors jamshred.log jamshred.oint jamshred.sound jamshred.tunnel kernel math math.constants math.order math.ranges shuffle sequences system ;
IN: jamshred.player

TUPLE: player < oint name sounds tunnel nearest-segment last-move speed ;

! speeds are in GL units / second
: default-speed ( -- speed ) 1.0 ;
: max-speed ( -- speed ) 30.0 ;

: <player> ( name sounds -- player )
    [ F{ 0 0 5 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } ] 2dip
    f f f default-speed player boa ;

: turn-player ( player x-radians y-radians -- )
    >r over r> left-pivot up-pivot ;

: roll-player ( player z-radians -- )
    forward-pivot ;

: to-tunnel-start ( player -- )
    [ tunnel>> first dup location>> ]
    [ tuck (>>location) (>>nearest-segment) ] bi ;

: play-in-tunnel ( player segments -- )
    >>tunnel to-tunnel-start ;

: update-nearest-segment ( player -- )
    [ tunnel>> ] [ dup nearest-segment>> nearest-segment ]
    [ (>>nearest-segment) ] tri ;

: moved ( player -- ) millis swap (>>last-move) ;

: speed-range ( -- range )
    max-speed [0,b] ;

: change-player-speed ( inc player -- )
    [ + speed-range clamp-to-range ] change-speed drop ;

: distance-to-move ( player -- distance )
    [ speed>> ] [ last-move>> millis dup >r swap - 1000 / * r> ]
    [ (>>last-move) ] tri ;

DEFER: (move-player)

: ?bounce ( distance-remaining player -- )
    over 0 > [
        [ dup nearest-segment>> bounce ] [ sounds>> bang ]
        [ (move-player) ] tri
    ] [
        2drop
    ] if ;

: move-player-distance ( distance-remaining player distance -- distance-remaining player )
    pick min tuck over go-forward [ - ] dip ;

: (move-player) ( distance-remaining player -- )
    over 0 <= [
        2drop
    ] [
        dup dup nearest-segment>> distance-to-collision
        move-player-distance ?bounce
    ] if ;

: move-player ( player -- )
    [ distance-to-move ] [ (move-player) ] [ update-nearest-segment ] tri ;

: update-player ( player -- )
    dup move-player nearest-segment>>
    white swap set-segment-color ;
