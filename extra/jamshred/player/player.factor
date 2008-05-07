! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors jamshred.log jamshred.oint jamshred.tunnel kernel math math.constants math.order sequences ;
IN: jamshred.player

TUPLE: player < oint name tunnel nearest-segment ;

: <player> ( name -- player )
    [ F{ 0 0 5 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } ] dip f f player boa ;

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

: max-speed ( -- speed )
    0.01 ;

: player-speed ( player -- speed )
    drop max-speed ;
    ! dup nearest-segment>> fraction-from-wall sq max-speed * ;

! : move-player ( player -- )
!     dup player-speed over go-forward update-nearest-segment ;
DEFER: (move-player)

: ?bounce ( distance-remaining player -- )
    over 0 > [
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
        dup dup nearest-segment>> distance-to-collision ! [ .s ] with-string-writer jamshred-log
        move-player-distance ?bounce
    ] if ;

: move-player ( player -- )
    [ player-speed ] [ (move-player) ] [ update-nearest-segment ] tri ;

: update-player ( player -- )
    dup move-player nearest-segment>>
    white swap set-segment-color ;
