! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic io kernel listener math memory namespaces
prettyprint sequences words ;

SYMBOL: inspector-slots

: sheet-numbers ( sheet -- sheet )
    dup [ peek ] map inspector-slots set
    dup length [ 1+ add* ] 2map ;

SYMBOL: inspector-stack

: inspecting ( -- obj ) inspector-stack get peek ;

: (inspect) ( obj -- )
    dup inspector-stack get push
    dup summary print
    sheet sheet-numbers sheet. ;

: go ( n -- ) 1- inspector-slots get nth (inspect) ;

: up ( -- ) inspector-stack get dup pop* pop (inspect) ;

: inspector-help ( -- )
    "Object inspector." print
    terpri
    "up -- return to previous object" [ up ] print-input
    "inspecting ( -- obj ) push current object" [ inspecting ] print-input
    "go ( n -- ) inspect nth slot" print ;

: inspector ( obj -- )
    inspector-help
    V{ } clone inspector-stack set
    (inspect) ;

: inspect ( obj -- )
    inspector-stack get [ (inspect) ] [ inspector ] if ;
