! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.mixin kernel namespaces
parser ui.gadgets ui.gadgets.scrollers ;
IN: ui.tools.common

SYMBOL: tool-dims

tool-dims global [ H{ } clone or ] change-at

MIXIN: tool

M: tool pref-dim*
    class tool-dims get at ;

M: tool layout*
    [ call-next-method ]
    [ [ dim>> ] [ class ] bi tool-dims get set-at ]
    bi ;

: TOOL:
    scan-word
    [ tool add-mixin-instance ]
    [ scan-object swap tool-dims get set-at ]
    bi ; parsing

SLOT: scroller

: com-page-up ( tool -- )
    scroller>> scroll-up-page ;

: com-page-down ( tool -- )
    scroller>> scroll-down-page ;

: com-scroll-up ( tool -- )
    scroller>> scroll-up-line ;

: com-scroll-down ( tool -- )
    scroller>> scroll-down-line ;
