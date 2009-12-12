! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar.format calendar.model fonts fry
grouping kernel math models.arrow namespaces sequences ui
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
    4 iota [ lcd-row ] with map "\n" join ;

: <time-display> ( model -- gadget )
    [ timestamp>hms lcd ] <arrow> <label-control>
    "99:99:99" lcd >>string
    monospace-font >>font ;

: time-window ( -- )
    [ time get <time-display> "Time" open-window ] with-ui ;

MAIN: time-window
