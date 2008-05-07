! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel opengl arrays sequences jamshred.log jamshred.player jamshred.tunnel math.vectors ;
IN: jamshred.game

TUPLE: jamshred tunnel players running ;

: <jamshred> ( -- jamshred )
    <random-tunnel> "Player 1" <player> 2dup swap play-in-tunnel 1array f
    jamshred boa ;

: jamshred-player ( jamshred -- player )
    ! TODO: support more than one player
    players>> first ;

: jamshred-update ( jamshred -- )
    dup running>> [
        jamshred-player update-player
    ] [ drop ] if ;

: toggle-running ( jamshred -- )
    [ running>> not ] [ (>>running) ] bi ;

: mouse-moved ( x-radians y-radians jamshred -- )
    jamshred-player -rot turn-player ;
