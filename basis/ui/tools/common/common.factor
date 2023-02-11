! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes combinators.short-circuit kernel ui
ui.gadgets ui.gadgets.borders ui.gadgets.scrollers
ui.gadgets.tracks ui.pens.solid ui.theme words ;

IN: ui.tools.common

: set-tool-dim ( class dim -- )
    "tool-dim" set-word-prop ;

: get-tool-dim ( class -- dim )
    "tool-dim" word-prop ;

TUPLE: tool < track ;

M: tool pref-dim*
    { [ class-of get-tool-dim ] [ call-next-method ] } 1|| ;

M: tool layout*
    [ call-next-method ]
    [
        dup fullscreen? [ drop ] [
            [ class-of ] [ dim>> ] bi set-tool-dim
        ] if
    ] bi ;

SLOT: scroller

: com-page-up ( tool -- )
    scroller>> scroll-up-page ;

: com-page-down ( tool -- )
    scroller>> scroll-down-page ;

: com-scroll-up ( tool -- )
    scroller>> scroll-up-line ;

: com-scroll-down ( tool -- )
    scroller>> scroll-down-line ;

: margins ( child -- border )
    { 9 9 } <filled-border> ;

: with-lines ( track -- track )
    dup orientation>> >>gap
    line-color <solid> >>interior ;

: white-interior ( track -- track )
    content-background <solid> >>interior ;
