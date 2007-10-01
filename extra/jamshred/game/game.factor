USING: kernel opengl arrays sequences jamshred jamshred.tunnel
jamshred.player math.vectors ;
IN: jamshred.game

TUPLE: jamshred tunnel players running ;

: <jamshred> ( -- jamshred )
    <random-tunnel> "Player 1" <player> 2dup swap play-in-tunnel 1array f
    jamshred construct-boa ;

: jamshred-player ( jamshred -- player )
    ! TODO: support more than one player
    jamshred-players first ;

: jamshred-update ( jamshred -- )
    dup jamshred-running [
        dup jamshred-tunnel swap jamshred-player update-player
    ] [ drop ] if ;

: toggle-running ( jamshred -- )
    dup jamshred-running not swap set-jamshred-running ;

: mouse-moved ( x-radians y-radians jamshred -- )
    jamshred-player -rot turn-player ;
