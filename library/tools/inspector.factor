! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: arrays generic io kernel listener math memory namespaces
prettyprint sequences words ;

SYMBOL: inspector-slots

: sheet-numbers ( sheet -- sheet )
    dup [ peek ] map inspector-slots set
    dup length [ 1+ add* ] 2map ;

SYMBOL: inspector-stack

: me ( -- obj ) inspector-stack get peek ;

: (inspect) ( obj -- )
    dup inspector-stack get push
    dup summary print
    sheet sheet-numbers sheet. ;

: go ( n -- ) 1- inspector-slots get nth (inspect) ;

: up ( -- ) inspector-stack get dup pop* pop (inspect) ;

: inspector-help ( -- )
    "Object inspector." print
    "up -- return to previous object" [ up ] print-quot
    "me ( -- obj ) push this object" [ me ] print-quot
    "go ( n -- ) inspect nth slot" print
    terpri ;

: inspector ( obj -- )
    inspector-help
    V{ } clone inspector-stack set
    (inspect) ;

: inspect ( obj -- )
    inspector-stack get [ (inspect) ] [ inspector ] if ;
