USING: sequences kernel math io calendar calendar.model
arrays models namespaces ui.gadgets ui.gadgets.labels
ui.gadgets.theme ui ;
IN: lcd

: lcd-digit ( row digit -- str )
    dup CHAR: : = [ drop 10 ] [ CHAR: 0 - ] if swap {
        "  _       _  _       _   _   _   _   _      "
        " | |  |   _| _| |_| |_  |_    | |_| |_|  *  "
        " |_|  |  |_  _|   |  _| |_|   | |_|   |  *  "
        "                                            "
    } nth >r 4 * dup 4 + r> subseq ;

: lcd-row ( num row -- string )
    [ swap lcd-digit ] curry { } map-as concat ;

: lcd ( digit-str -- string )
    4 [ lcd-row ] with map "\n" join ;

: hh:mm:ss ( timestamp -- string )
    {
        timestamp-hour timestamp-minute timestamp-second
    } get-slots >fixnum 3array [ pad-00 ] map ":" join ;

: <time-display> ( timestamp -- gadget )
    [ hh:mm:ss lcd ] <filter> <label-control>
    "99:99:99" lcd over set-label-string
    monospace-font over set-label-font ;

: time-window ( -- )
    [ time get <time-display> "Time" open-window ] with-ui ;

MAIN: time-window
