! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: models sequences ui.gadgets.labels ui.gadgets.theme
ui.gadgets.tracks ui.gadgets.worlds ui.gadgets ui kernel
calendar ;
IN: ui.gadgets.status-bar

: <status-bar> ( model -- gadget )
    1/10 seconds <delay> [ "" like ] <filter> <label-control>
    dup reverse-video-theme
    t over set-gadget-root? ;

: open-status-window ( gadget title -- )
    >r [
        1 track,
        f <model> dup <status-bar> f track,
    ] { 0 1 } make-track r> rot <world> open-world-window ;
