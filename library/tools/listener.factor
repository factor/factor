! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: listener
USING: errors hashtables io kernel math memory namespaces
parser sequences strings styles vectors words ;

SYMBOL: quit-flag
SYMBOL: listener-hook

: bye ( -- ) quit-flag on ;

: (read-multiline) ( quot depth -- newquot ? )
    >r readln dup [
        (parse) depth r> dup >r <= [
            r> drop t
        ] [
            r> (read-multiline)
        ] if
    ] [
        r> 2drop f
    ] if ;

: read-multiline ( -- quot ? )
    [
        f depth (read-multiline) >r >quotation r> in get
    ] with-parser in set ;

: prompt. ( -- )
    in get H{ { background { 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    prompt. [
        listener-hook get call
        read-multiline [ call ] [ drop bye ] if
    ] try ;

: listener ( -- )
    quit-flag get [ quit-flag off ] [ listen listener ] if ;

: print-banner ( -- )
    "Factor " write version write
    " on " write os write "/" write cpu print ;

IN: shells

: tty ( -- )
    [
        use [ clone ] change
        print-banner
        listener
    ] with-scope ;
