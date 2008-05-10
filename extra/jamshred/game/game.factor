! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel opengl arrays sequences jamshred.log jamshred.player jamshred.sound jamshred.tunnel math.vectors ;
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

