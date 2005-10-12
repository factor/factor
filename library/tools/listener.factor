! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: errors io kernel lists math memory namespaces parser
presentation sequences strings styles vectors words ;

SYMBOL: listener-prompt
SYMBOL: quit-flag

SYMBOL: listener-hook
SYMBOL: datastack-hook
SYMBOL: callstack-hook

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

: listener ( -- )
    #! Run a listener loop that executes user input.
    quit-flag get [ quit-flag off ] [ listen listener ] if ;

: credits ( -- )
    "Slava Pestov:       dup drop swap >r r>" print
    "Alex Chapman:       OpenGL binding" print
    "Doug Coleman:       Mersenne Twister random number generator" print
    "Chris Double:       continuation-based web framework" print
    "Mackenzie Straight: Windows port" print ;

: print-banner ( -- )
    "Factor " write version write
    " on " write os write "/" write cpu write
    ". For credits, type ``credits''." print ;

IN: shells

: tty print-banner listener ;
