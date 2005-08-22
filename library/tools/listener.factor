! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: errors io kernel lists math memory namespaces parser
presentation sequences strings styles vectors words ;

SYMBOL: listener-prompt
SYMBOL: quit-flag
SYMBOL: listener-hook

global [ "  " listener-prompt set ] bind

: bye ( -- )
    #! Exit the current listener.
    quit-flag on ;

: (read-multiline) ( quot depth -- quot ? )
    #! Flag indicates EOF.
    >r readln dup [
        (parse) depth r> dup >r <= [
            ( we're done ) r> drop t
        ] [
            ( more input needed ) r> (read-multiline)
        ] ifte
    ] [
        ( EOF ) r> 2drop f
    ] ifte ;

: read-multiline ( -- quot ? )
    #! Keep parsing until the end is reached. Flag indicates
    #! EOF.
    [ f depth (read-multiline) >r reverse r> ] with-parser ;

: listen ( -- )
    #! Wait for user input, and execute.
    listener-prompt get write flush [
        read-multiline
        [ call listener-hook get call ] [ bye ] ifte
    ] try ;

: listener ( -- )
    #! Run a listener loop that executes user input.
    quit-flag get [ quit-flag off ] [ listen listener ] ifte ;

: print-banner ( -- )
    "Factor " write version write
    " :: http://factor.sourceforge.net :: " write
    os write
    "/" write cpu print
    "(C) 2003, 2005 Slava Pestov, Chris Double, Mackenzie Straight" print ;

IN: shells

: tty print-banner listener ;
