! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel accessors math math.order arrays ;
IN: math.rectangles.positioning

! Some geometry code for positioning popups and menus
! in a semi-intelligent manner

: popup-x ( visible-rect popup-dim screen-dim -- x )
    [ loc>> first ] 2dip swap [ first ] bi@ - min ;

: preferred-y ( visible-rect -- y )
    [ loc>> ] [ dim>> ] bi [ second ] bi@ + ;

: alternate-y ( visible-rect popup-dim -- y )
    [ loc>> ] dip [ second ] bi@ - ;

: popup-fits? ( visible-rect popup-dim screen-dim -- ? )
    [ [ preferred-y ] [ second ] bi* + ] dip second < ;

: popup-y ( visible-rect popup-dim screen-dim -- y )
    3dup popup-fits? [ 2drop preferred-y ] [ drop alternate-y ] if ;

: popup-loc ( visible-rect popup-dim screen-dim -- loc )
    [ popup-x ] [ popup-y ] 3bi 2array ;
