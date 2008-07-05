! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models models.delay models.filter
sequences ui.gadgets.labels ui.gadgets.theme ui.gadgets.tracks
ui.gadgets.worlds ui.gadgets ui kernel calendar ;
IN: ui.gadgets.status-bar

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <filter> <label-control>
    reverse-video-theme
    t >>root? ;

: open-status-window ( gadget title -- )
    >r [
        1 track,
        f <model> dup <status-bar> f track,
    ] { 0 1 } make-track r> rot <world> open-world-window ;
