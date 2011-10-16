! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel accessors math math.vectors
math.rectangles math.order arrays locals fry
combinators.short-circuit ;
IN: math.rectangles.positioning

! Some geometry code for positioning popups and menus
! in a semi-intelligent manner

<PRIVATE

: adjust-visible-rect ( visible-rect popup-dim screen-dim -- visible-rect' )
    [ drop clone ] dip '[ _ vmin ] change-loc ;

: popup-x ( visible-rect popup-dim screen-dim -- x )
    [ loc>> first ] 2dip swap [ first ] bi@ - min 0 max ;

: preferred-y ( visible-rect -- y )
    rect-bounds [ second ] bi@ + ;

: alternate-y ( visible-rect popup-dim -- y )
    [ loc>> ] dip [ second ] bi@ - ;

: preferred-fit? ( visible-rect popup-dim screen-dim -- ? )
    [ [ preferred-y ] [ second ] bi* + ] dip second < ;

: alternate-fit? ( visible-rect popup-dim -- ? )
    alternate-y 0 >= ;

: popup-y ( visible-rect popup-dim screen-dim -- y )
    3dup { [ preferred-fit? not ] [ drop alternate-fit? ] } 3&&
    [ drop alternate-y ] [ 2drop preferred-y ] if ;

: popup-loc ( visible-rect popup-dim screen-dim -- loc )
    [ popup-x ] [ popup-y ] 3bi 2array ;

:: popup-dim ( loc popup-dim screen-dim -- dim )
    screen-dim loc v- popup-dim vmin ;

PRIVATE>

: popup-rect ( visible-rect popup-dim screen-dim -- rect )
    [ adjust-visible-rect ] 2keep
    [ popup-loc dup ] 2keep popup-dim <rect> ;
