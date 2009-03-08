! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel math io calendar grouping
calendar.format calendar.model fonts arrays models models.arrow
namespaces ui.gadgets ui.gadgets.labels ui ;
IN: lcd

: lcd-digit ( row digit -- str )
    dup CHAR: : = [ drop 10 ] [ CHAR: 0 - ] if swap {
        "  _       _  _       _   _   _   _   _      "
        " | |  |   _| _| |_| |_  |_    | |_| |_|  *  "
        " |_|  |  |_  _|   |  _| |_|   | |_|   |  *  "
        "                                            "
    } nth 4 <groups> nth ;

: lcd-row ( num row -- string )
    [ swap lcd-digit ] curry { } map-as concat ;

: lcd ( digit-str -- string )
    4 [ lcd-row ] with map "\n" join ;

: hh:mm:ss ( timestamp -- string )
    [ hour>> ] [ minute>> ] [ second>> >fixnum ] tri
    3array [ pad-00 ] map ":" join ;

: <time-display> ( timestamp -- gadget )
    [ hh:mm:ss lcd ] <arrow> <label-control>
    "99:99:99" lcd >>string
    monospace-font >>font ;

: time-window ( -- )
    [ time get <time-display> "Time" open-window ] with-ui ;

MAIN: time-window
