! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar colors colors.constants fonts kernel
models models.arrow models.delay sequences summary ui
ui.gadgets ui.gadgets.labels ui.gadgets.tracks
ui.gadgets.worlds ui.pens.solid ui.private ;
IN: ui.gadgets.status-bar

: status-bar-font ( -- font )
    sans-serif-font clone
    T{ rgba f 0.216 0.243 0.282 1.0 } >>background
    COLOR: white >>foreground ;

: status-bar-theme ( label -- label )
    status-bar-font >>font
    T{ rgba f 0.216 0.243 0.282 1.0 } <solid> >>interior ;

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <arrow> <label-control>
    status-bar-theme
    t >>root? ;

: open-status-window ( gadget title/attributes -- )
    ?attributes f <model> >>status <world>
    dup status>> <status-bar> f track-add
    open-world-window ;

: show-summary ( object gadget -- )
    [ [ summary ] [ "" ] if* ] dip show-status ;
