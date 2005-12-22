! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic io kernel listener memory namespaces
prettyprint sequences words ;

! Interactive inspector
SYMBOL: inspector-slots

: sheet-numbers ( sheet -- sheet )
    dup first length >array 1array swap append
    dup peek inspector-slots set ;

SYMBOL: inspector-stack

: inspecting ( -- obj ) inspector-stack get peek ;

: (inspect) ( obj -- )
    dup inspector-stack get push
    dup summary print
    sheet sheet-numbers sheet. ;

: inspector-help ( -- )
    "Object inspector." print
    "inspecting ( -- obj ) push current object" print
    "go ( n -- ) inspect nth slot" print
    "up -- return to previous object" print
    "bye -- exit inspector" print ;

: inspector ( obj -- )
    [
        inspector-help
        terpri
        "inspector " listener-prompt set
        V{ } clone inspector-stack set
        (inspect)
        listener
    ] with-scope ;

: inspect ( obj -- )
    #! Start an inspector if its not already running.
    inspector-stack get [ (inspect) ] [ inspector ] if ;

: go ( n -- ) inspector-slots get nth (inspect) ;

: up ( -- ) inspector-stack get dup pop* pop (inspect) ;
