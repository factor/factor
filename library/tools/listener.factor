! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: listener
USING: errors hashtables io kernel math memory namespaces
parser sequences strings styles vectors words ;

SYMBOL: listener-prompt
SYMBOL: quit-flag

SYMBOL: listener-hook
SYMBOL: datastack-hook
SYMBOL: error-hook

"  " listener-prompt set-global
[ drop terpri debug-help ] error-hook set-global

: bye ( -- ) quit-flag on ;

: (read-multiline) ( quot depth -- quot ? )
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
    [
        f depth (read-multiline) >r >quotation r> in get
    ] with-parser in set ;

: listen-try
    [
        print-error error-continuation get error-hook get call
    ] recover ;

: listen ( -- )
    listener-hook get call
    listener-prompt get write flush
    [ read-multiline [ call ] [ bye ] if ]
    listen-try ;

: (listener) ( -- )
    quit-flag get [ quit-flag off ] [ listen (listener) ] if ;

: listener ( -- )
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
