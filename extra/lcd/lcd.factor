USING: sequences kernel math io ;
IN: lcd

: lcd-digit ( digit row -- str )
    {
        "  _       _  _       _   _   _   _   _  "
        " | |  |   _| _| |_| |_  |_    | |_| |_| "     
        " |_|  |  |_  _|   |  _| |_|   | |_|   | "
    } nth >r 4 * dup 4 + r> subseq ;

: lcd-row ( num row -- )
    swap [ CHAR: 0 - swap lcd-digit write ] curry* each ;

: lcd ( digit-str -- )
    3 [ lcd-row nl ] curry* each ;

: lcd-demo ( -- ) "31337" lcd ;

MAIN: lcd-demo
