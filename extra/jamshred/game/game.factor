! Copyright (C) 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays jamshred.player jamshred.sound
jamshred.tunnel kernel math math.constants sequences ;
IN: jamshred.game

TUPLE: jamshred sounds tunnel players running quit ;

: <jamshred> ( -- jamshred )
    <sounds> <random-tunnel> "Player 1" pick <player>
    2dup swap play-in-tunnel 1array f f jamshred boa ;

: jamshred-player ( jamshred -- player )
    ! TODO: support more than one player
    players>> first ;

: jamshred-update ( jamshred -- )
    dup running>> [
        jamshred-player update-player
    ] [ drop ] if ;

: toggle-running ( jamshred -- )
    dup running>> [
        f >>running drop
    ] [
        [ jamshred-player moved ]
        [ t >>running drop ] bi
    ] if ;

: mouse-moved ( x-radians y-radians jamshred -- )
    jamshred-player -rot turn-player ;

CONSTANT: units-per-full-roll 50

: jamshred-roll ( jamshred n -- )
    [ jamshred-player ] dip 2 pi * * units-per-full-roll / roll-player ;

: mouse-scroll-x ( jamshred x -- ) jamshred-roll ;

: mouse-scroll-y ( jamshred y -- )
    neg swap jamshred-player change-player-speed ;
