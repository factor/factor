USING: sequences kernel math io ;

: lcd-digit ( digit row -- str )
    {
        "  _       _  _       _   _   _   _   _  "
        " | |  |   _| _| |_| |_  |_    | |_| |_| "     
        " |_|  |  |_  _|   |  _| |_|   | |_|   | "
    } nth >r 4 * dup 4 + r> subseq ;

: lcd-row ( num row -- )
    swap [ CHAR: 0 - swap lcd-digit write ] each-with ;

: lcd ( digit-str -- )
    3 [ 2dup lcd-row terpri ] repeat drop ;
