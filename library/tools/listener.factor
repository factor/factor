! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: errors kernel lists math memory namespaces parser stdio
strings presentation words unparser vectors ansi ;

SYMBOL: cont-prompt
SYMBOL: listener-prompt
SYMBOL: quit-flag

global [
    "..." cont-prompt set
    "ok" listener-prompt set
] bind

: prompt. ( text -- )
    "prompt" style write-attr
    ! Print the space without a style, to workaround a bug in
    ! the GUI listener where the style from the prompt carries
    ! over to the input
    " " write flush ;

: exit ( -- )
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
    f depth (read-multiline) >r reverse r> ;

: listen ( -- )
    #! Wait for user input, and execute.
    listener-prompt get prompt.
    [ read-multiline [ call ] [ exit ] ifte ] try ;

: listener ( -- )
    #! Run a listener loop that executes user input.
    quit-flag get [ quit-flag off ] [ listen listener ] ifte ;

: print-banner ( -- )
    "Factor " write version write
    " (OS: " write os write
    " CPU: " write cpu write
    ")" print
    "Copyright (C) 2003, 2005 Slava Pestov" print
    "Copyright (C) 2004, 2005 Chris Double" print
    "Copyright (C) 2004, 2005 Mackenzie Straight" print
    "Type ``exit'' to exit, ``help'' for help." print
    terpri
    room.
    terpri ;

: help ( -- )
    "SESSION:" print
    "\"foo.image\" save-image   -- save heap to a file" print
    "room.                    -- show memory usage" print
    "heap-stats.              -- memory allocation breakdown" print
    "garbage-collection       -- force a GC" print
    "exit                     -- exit interpreter" print
    terpri
    "WORDS:" print
    "vocabs.                  -- list vocabularies" print 
    "\"math\" words.            -- list the math vocabulary" print
    "\"str\" apropos.           -- list all words containing str" print
    "\\ neg see                -- show word definition" print
    "\\ car usages.            -- list all words invoking car" print
    terpri
    "STACKS:" print
    ".s .r .n .c              -- show contents of the 4 stacks" print
    "clear                    -- clear datastack" print
    terpri
    "OBJECTS:" print
    "global describe          -- list global variables." print
    "\"foo\" get .              -- print a variable value." print
    ".                        -- print top of stack." print
    terpri
    "PROFILER:                [ ... ] call-profile" print
    "                         [ ... ] allot-profile" print
    "TRACE:                   [ ... ] trace" print
    "SINGLE STEP:             [ ... ] walk" print
    terpri
    "HTTP SERVER:             USE: httpd 8888 httpd" print
    "TELNET SERVER:           USE: telnetd 9999 telnetd" print ;

IN: shells

: tty
    print-banner listener ;
