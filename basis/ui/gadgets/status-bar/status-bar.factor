! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models models.delay models.filter
sequences ui.gadgets.labels ui.gadgets.tracks
ui.gadgets.worlds ui.gadgets ui kernel calendar summary ;
IN: ui.gadgets.status-bar

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <filter> <label-control>
    reverse-video-theme
    t >>root? ;

: open-status-window ( gadget title -- )
    f <model> [ <world> ] keep
    <status-bar> f track-add
    open-world-window ;

: show-summary ( object gadget -- )
    [ [ summary ] [ "" ] if* ] dip show-status ;
