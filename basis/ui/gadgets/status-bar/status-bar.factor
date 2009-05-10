! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models models.delay models.arrow
sequences ui.gadgets.labels ui.gadgets.tracks
ui.gadgets.worlds ui.gadgets ui ui.private kernel calendar summary ;
IN: ui.gadgets.status-bar

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <arrow> <label-control>
    reverse-video-theme
    t >>root? ;

: open-status-window ( gadget title/attributes -- )
    ?attributes f <model> >>status <world>
    dup status>> <status-bar> f track-add
    open-world-window ;

: show-summary ( object gadget -- )
    [ [ summary ] [ "" ] if* ] dip show-status ;
