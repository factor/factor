! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators jamshred.log jamshred.oint jamshred.sound jamshred.tunnel kernel locals math math.constants math.order math.ranges math.vectors math.matrices shuffle sequences system ;
USE: tools.walker
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

: update-time ( player -- seconds-passed )
    millis swap [ last-move>> - 1000 / ] [ (>>last-move) ] 2bi ;

: moved ( player -- ) millis swap (>>last-move) ;

: speed-range ( -- range )
    max-speed [0,b] ;

: change-player-speed ( inc player -- )
    [ + speed-range clamp-to-range ] change-speed drop ;

: multiply-player-speed ( n player -- )
    [ * speed-range clamp-to-range ] change-speed drop ; 

: distance-to-move ( seconds-passed player -- distance )
    speed>> * ;

: bounce ( d-left player -- d-left' player )
    {
        [ dup nearest-segment>> bounce-off-wall ]
        [ sounds>> bang ]
        [ 3/4 swap multiply-player-speed ]
        [ ]
    } cleave ;

:: move-player-on-heading ( d-left player distance heading -- d-left' player )
    [let* | d-to-move [ d-left distance min ]
            move-v [ d-to-move heading n*v ] |
        move-v player location+
        player update-nearest-segment
        d-left d-to-move - player ] ;

: (distance) ( player -- segments current location )
    [ tunnel>> ] [ nearest-segment>> ] [ location>> ] tri ;

: distance-to-next-segment ( player -- distance )
    [ (distance) ] [ forward>> distance-to-heading-segment ] bi ;

: distance-to-collision ( player -- distance )
    dup nearest-segment>> (distance-to-collision) ;

: move-toward-wall ( d-left player d-to-wall -- d-left' player )
    over distance-to-next-segment min
    over forward>> move-player-on-heading ;

: from ( player -- radius distance-from-centre )
    [ nearest-segment>> dup radius>> swap ] [ location>> ] bi
    distance-from-centre ;

: distance-from-wall ( player -- distance ) from - ;
: fraction-from-centre ( player -- fraction ) from swap / ;
: fraction-from-wall ( player -- fraction )
    fraction-from-centre 1 swap - ;

: ?move-player-freely ( d-left player -- d-left' player )
    ! 2dup [ 0 > ] [ fraction-from-wall 0 > ] bi* and [
    over 0 > [
        dup distance-to-collision dup 0 > [
            move-toward-wall ?move-player-freely
        ] [ drop ] if
    ] when ;

: drag-heading ( player -- heading )
    [ forward>> ] [ nearest-segment>> forward>> proj ] bi ;

: drag-distance-to-next-segment ( player -- distance )
    [ (distance) ] [ drag-heading distance-to-heading-segment ] bi ;

: drag-player ( d-left player -- d-left' player )
    dup [ drag-distance-to-next-segment ]
    [ drag-heading move-player-on-heading ] bi ;

: (move-player) ( d-left player -- d-left' player )
    ?move-player-freely over 0 > [
        ! bounce
        drag-player
        ! (move-player)
    ] when ;

: move-player ( player -- )
    [ update-time ] [ distance-to-move ] [ (move-player) 2drop ] tri ;

: update-player ( player -- )
    [ move-player ] [ nearest-segment>> white swap (>>color) ] bi ;
