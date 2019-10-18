! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: errors hashtables io kernel lists math memory namespaces
parser sequences strings styles vectors words ;

SYMBOL: listener-prompt
SYMBOL: quit-flag

SYMBOL: listener-hook
SYMBOL: datastack-hook

"  " listener-prompt set-global

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
        ] if
    ] [
        ( EOF ) r> 2drop f
    ] if ;

: read-multiline ( -- quot ? )
    #! Keep parsing until the end is reached. Flag indicates
    #! EOF.
    [ f depth (read-multiline) >r reverse r> ] with-parser ;

: listen ( -- )
    #! Wait for user input, and execute.
    listener-hook get call
    listener-prompt get write flush
    [ read-multiline [ call ] [ bye ] if ] try ;

: (listener) ( -- )
    quit-flag get [ quit-flag off ] [ listen (listener) ] if ;

: listener ( -- )
    #! Run a listener loop that executes user input. We start
    #! the listener in a new scope and copy the vocabulary
    #! search path.
    [
        use [ clone ] change
        [ datastack ] datastack-hook set
        (listener)
    ] with-scope ;

: print-banner ( -- )
    "Factor " write version write
    " on " write os write "/" write cpu print ;

IN: shells

: tty print-banner listener ;
