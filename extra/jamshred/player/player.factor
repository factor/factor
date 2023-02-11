! Copyright (C) 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.

USING: accessors colors combinators jamshred.oint
jamshred.sound jamshred.tunnel kernel math math.order
math.vectors ranges sequences specialized-arrays
strings system ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: jamshred.player

TUPLE: player < oint
    { name string }
    { sounds sounds }
    tunnel
    nearest-segment
    { last-move integer }
    { speed float } ;

! speeds are in GL units / second
CONSTANT: default-speed 1.0
CONSTANT: max-speed 30.0

: <player> ( name sounds -- player )
    [ float-array{ 0 0 5 } float-array{ 0 0 -1 } float-array{ 0 1 0 } float-array{ -1 0 0 } ] 2dip
    f f 0 default-speed player boa ;

: turn-player ( player x-radians y-radians -- )
    overd left-pivot up-pivot ;

: roll-player ( player z-radians -- )
    forward-pivot ;

: to-tunnel-start ( player -- )
    dup tunnel>> first
    [ >>nearest-segment ]
    [ location>> >>location ] bi drop ;

: play-in-tunnel ( player segments -- )
    >>tunnel to-tunnel-start ;

: update-time ( player -- seconds-passed )
    nano-count swap [ last-move>> - 1,000,000,000 / ] [ last-move<< ] 2bi ;

: moved ( player -- ) nano-count swap last-move<< ;

: speed-range ( -- range )
    max-speed [0..b] ;

: change-player-speed ( inc player -- )
    [ + 0 max-speed clamp ] change-speed drop ;

: multiply-player-speed ( n player -- )
    [ * 0 max-speed clamp ] change-speed drop ;

: distance-to-move ( seconds-passed player -- distance )
    speed>> * ;

: bounce ( d-left player -- d-left' player )
    {
        [ dup nearest-segment>> bounce-off-wall ]
        [ sounds>> bang ]
        [ 3/4 swap multiply-player-speed ]
        [ ]
    } cleave ;

:: (distance) ( heading player -- current next location heading )
    player nearest-segment>>
    player [ tunnel>> ] [ nearest-segment>> ] bi heading heading-segment
    player location>> heading ;

: distance-to-heading-segment ( heading player -- distance )
    (distance) distance-to-next-segment ;

: distance-to-heading-segment-area ( heading player -- distance )
    (distance) distance-to-next-segment-area ;

: distance-to-collision ( player -- distance )
    dup nearest-segment>> (distance-to-collision) ;

: almost-to-collision ( player -- distance )
    distance-to-collision 0.1 - dup 0 < [ drop 0 ] when ;

: from ( player -- radius distance-from-center )
    [ nearest-segment>> dup radius>> swap ] [ location>> ] bi
    distance-from-center ;

: distance-from-wall ( player -- distance ) from - ;
: fraction-from-center ( player -- fraction ) from swap / ;
: fraction-from-wall ( player -- fraction )
    fraction-from-center 1 swap - ;

: update-nearest-segment2 ( heading player -- )
    2dup distance-to-heading-segment-area 0 <= [
        [ tunnel>> ] [ nearest-segment>> rot heading-segment ]
        [ nearest-segment<< ] tri
    ] [
        2drop
    ] if ;

:: move-player-on-heading ( d-left player distance heading -- d-left' player )
    d-left distance min :> d-to-move
    d-to-move heading n*v :> move-v

    move-v player location+
    heading player update-nearest-segment2
    d-left d-to-move - player ;

: distance-to-move-freely ( player -- distance )
    [ almost-to-collision ]
    [ [ forward>> ] keep distance-to-heading-segment-area ] bi min ;

: ?move-player-freely ( d-left player -- d-left' player )
    over 0 > [
        ! must make sure we are moving a significant distance, otherwise
        ! we can recurse endlessly due to floating-point imprecision.
        ! (at least I /think/ that's what causes it...)
        dup distance-to-move-freely dup 0.1 > [
            over forward>> move-player-on-heading ?move-player-freely
        ] [ drop ] if
    ] when ;

: drag-heading ( player -- heading )
    [ forward>> ] [ nearest-segment>> forward>> proj ] bi ;

: drag-player ( d-left player -- d-left' player )
    dup [ [ drag-heading ] keep distance-to-heading-segment-area ]
    [ drag-heading move-player-on-heading ] bi ;

: (move-player) ( d-left player -- d-left' player )
    ?move-player-freely over 0 > [
        ! bounce
        drag-player
    ] when ;

: move-player ( player -- )
    [ update-time ] [ distance-to-move ] [ (move-player) 2drop ] tri ;

: update-player ( player -- )
    [ move-player ] [ nearest-segment>> COLOR: white swap color<< ] bi ;
