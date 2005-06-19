USING: sequences kernel math io strings ;

: lcd-digit ( digit row -- str )
    {
        "  _       _  _       _   _   _   _   _  "
        " | |  |   _| _| |_| |_  |_    | |_| |_| "     
        " |_|  |  |_  _|   |  _| |_|   | |_|   | "
    } nth >r 4 * dup 4 + r> substring ;

: lcd-row ( num row -- )
    swap [ CHAR: 0 - over lcd-digit write ] each drop ;

: lcd ( num -- str )
    3 [ 2dup lcd-row terpri ] repeat drop ;
