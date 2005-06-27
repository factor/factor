! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: ansi errors io kernel lists math memory namespaces parser
presentation sequences strings styles unparser vectors words ;

SYMBOL: cont-prompt
SYMBOL: listener-prompt
SYMBOL: quit-flag

global [
    "..." cont-prompt set
    "ok" listener-prompt set
] bind

: prompt. ( text -- )
    [ [[ "bold" t ]] [[ font-style bold ]] ] write-attr
    ! Print the space without a style, to workaround a bug in
    ! the GUI listener where the style from the prompt carries
    ! over to the input
    bl flush ;

: bye ( -- )
    #! Exit the current listener.
    quit-flag on ;

: (read-multiline) ( quot depth -- quot ? )
    #! Flag indicates EOF.
    >r read-line dup [
        (parse) depth r> dup >r <= [
            ( we're done ) r> drop t
        ] [
            ( more input needed ) r> cont-prompt get prompt.
            (read-multiline)
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
    listener-prompt get prompt.
    [ read-multiline [ call ] [ bye ] ifte ] try ;

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
