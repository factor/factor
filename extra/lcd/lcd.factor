! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format fonts fry grouping
kernel math sequences timers threads ui ui.gadgets
ui.gadgets.labels ;
IN: lcd

: lcd-digit ( digit row -- str )
    [ dup CHAR: : = [ drop 10 ] [ CHAR: 0 - ] if ] dip {
        "  _       _  _       _   _   _   _   _      "
        " | |  |   _| _| |_| |_  |_    | |_| |_|  *  "
        " |_|  |  |_  _|   |  _| |_|   | |_|   |  *  "
        "                                            "
    } nth 4 <groups> nth ;

: lcd-row ( row digit -- string )
    '[ _ lcd-digit ] { } map-as concat ;

: lcd ( digit-str -- string )
    4 <iota> [ lcd-row ] with map "\n" join ;

TUPLE: time-display < label timer ;

: <time-display> ( -- gadget )
    "99:99:99" lcd time-display new-label
        monospace-font >>font
        dup '[ now timestamp>hms lcd _ string<< ]
        f 1 seconds <timer> >>timer ;

M: time-display graft*
    [ timer>> start-timer yield ] [ call-next-method ] bi ;

M: time-display ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

MAIN-WINDOW: time-window { { title "Time" } }
    <time-display> >>gadgets ;
