! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar colors fonts kernel models
models.arrow models.delay sequences summary ui
ui.gadgets.borders ui.gadgets.labels ui.gadgets.tracks
ui.gadgets.worlds ui.pens.solid ui.private ui.theme ;
IN: ui.gadgets.status-bar

: status-bar-font ( -- font )
    sans-serif-font clone
    status-bar-background >>background
    status-bar-foreground >>foreground ;

: status-bar-theme ( label -- label )
    status-bar-font >>font
    status-bar-background <solid> >>interior ;

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <arrow> <label-control>
    status-bar-theme
    t >>root? ;

: open-status-window ( gadget title/attributes -- )
    ?attributes f <model> >>status <world>
    dup status>> <status-bar> 
    { 7 2 } <filled-border> status-bar-background <solid> >>interior
    f track-add
    open-world-window ;

: show-summary ( object gadget -- )
    [ [ safe-summary ] [ "" ] if* ] dip show-status ;
