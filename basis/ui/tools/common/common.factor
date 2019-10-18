! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.mixin kernel namespaces
parser ui.gadgets ui.gadgets.scrollers ui.gadgets.tracks
combinators.short-circuit ;
IN: ui.tools.common

SYMBOL: tool-dims

tool-dims [ H{ } clone ] initialize

TUPLE: tool < track ;

M: tool pref-dim*
    { [ class-of tool-dims get-global at ] [ call-next-method ] } 1|| ;

M: tool layout*
    [ call-next-method ]
    [ [ dim>> ] [ class-of ] bi tool-dims get-global set-at ]
    bi ;

: set-tool-dim ( dim class -- ) tool-dims get-global set-at ;

SLOT: scroller

: com-page-up ( tool -- )
    scroller>> scroll-up-page ;

: com-page-down ( tool -- )
    scroller>> scroll-down-page ;

: com-scroll-up ( tool -- )
    scroller>> scroll-up-line ;

: com-scroll-down ( tool -- )
    scroller>> scroll-down-line ;
