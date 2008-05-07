! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors jamshred.log jamshred.oint jamshred.tunnel kernel math math.constants math.order sequences system ;
IN: jamshred.player

TUPLE: player < oint name tunnel nearest-segment last-move ;

: <player> ( name -- player )
    [ F{ 0 0 5 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } ] dip f f f player boa ;

: turn-player ( player x-radians y-radians -- )
    >r over r> left-pivot up-pivot ;

: to-tunnel-start ( player -- )
    [ tunnel>> first dup location>> ]
    [ tuck (>>location) (>>nearest-segment) ] bi ;

: play-in-tunnel ( player segments -- )
    >>tunnel to-tunnel-start ;

: update-nearest-segment ( player -- )
    [ tunnel>> ] [ dup nearest-segment>> nearest-segment ]
    [ (>>nearest-segment) ] tri ;

: moved ( player -- ) millis swap (>>last-move) ;
: max-speed ( -- speed ) 1.0 ; ! units/second

: player-speed ( player -- speed )
    drop max-speed ;
    ! dup nearest-segment>> fraction-from-wall sq max-speed * ;

: distance-to-move ( player -- distance )
    [ player-speed ] [ last-move>> millis dup >r swap - 1000 / * r> ]
    [ (>>last-move) ] tri ;

DEFER: (move-player)

USE: morse
: ?bounce ( distance-remaining player -- )
    over 0 > [
        "e" play-as-morse
        [ dup nearest-segment>> bounce ]
        ! [ (move-player) ] ! uncomment when bounce works...
        [ 2drop ]
        bi
    ] [
        2drop
    ] if ;

: move-player-distance ( distance-remaining player distance -- distance-remaining player )
    pick min tuck over go-forward [ - ] dip ;

USE: prettyprint
USE: io.streams.string
: (move-player) ( distance-remaining player -- )
    over 0 <= [
        2drop
    ] [
        dup dup nearest-segment>> distance-to-collision
        [ dup . ] with-string-writer jamshred-log
        move-player-distance ?bounce
    ] if ;

: move-player ( player -- )
    [ distance-to-move ] [ (move-player) ] [ update-nearest-segment ] tri ;

: update-player ( player -- )
    dup move-player nearest-segment>>
    white swap set-segment-color ;
