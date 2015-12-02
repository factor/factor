! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators kernel math sequences
snake-game.constants ;

IN: snake-game.util

: screen-loc ( loc -- loc )
    [ snake-game-cell-size * ] map ;

: offset ( loc dim -- loc )
    [ + ] 2map ;

: ?roll-over ( x max -- x )
    {
        { [ 2dup >= ] [ 2drop 0 ] }
        { [ over neg? ] [ nip 1 - ] }
        [ drop ]
    } cond ;

: ?roll-over-x ( x -- x )
    snake-game-dim first ?roll-over ;

: ?roll-over-y ( y -- y )
    snake-game-dim second ?roll-over ;

: move ( loc dim -- loc )
    offset first2
    [ ?roll-over-x ] [ ?roll-over-y ] bi* 2array ;

: relative-loc ( loc dir -- loc )
    {
        { :left  [ { -1  0 } move ] }
        { :right [ {  1  0 } move ] }
        { :up    [ {  0 -1 } move ] }
        { :down  [ {  0  1 } move ] }
    } case ;

: opposite-dir ( dir -- dir )
    H{
        { :left  :right }
        { :right :left }
        { :up    :down }
        { :down  :up }
    } at ;
