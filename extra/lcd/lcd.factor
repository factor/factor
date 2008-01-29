USING: sequences kernel math io ;
IN: lcd

: lcd-digit ( row digit -- str )
    dup CHAR: : = [ drop 10 ] [ CHAR: 0 - ] if swap {
        "  _       _  _       _   _   _   _   _      "
        " | |  |   _| _| |_| |_  |_    | |_| |_|  *  "
        " |_|  |  |_  _|   |  _| |_|   | |_|   |  *  "
    } nth >r 4 * dup 4 + r> subseq ;

: lcd-row ( num row -- string )
    [ swap lcd-digit ] curry { } map-as concat ;

: lcd ( digit-str -- string )
    3 [ lcd-row ] with map "\n" join ;

: lcd-demo ( -- ) "31337" lcd print ;

MAIN: lcd-demo
