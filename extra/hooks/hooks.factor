! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: assocs digraphs kernel namespaces sequences ;
IN: hooks

: hooks ( -- hooks )
    \ hooks global [ drop H{ } clone ] cache ;

: hook-graph ( hook -- graph )
    hooks [ drop <digraph> ] cache ;

: reset-hook ( hook -- )
    <digraph> swap hooks set-at ;

: add-hook ( key quot hook -- )
    #! hook should be a symbol. Note that symbols with the same name but
    #! different vocab are not equal
    hook-graph add-vertex ; 

: before ( key1 key2 hook -- )
    hook-graph add-edge ;

: after ( key1 key2 hook -- )
    swapd before ;

: call-hook ( hook -- )
    hook-graph topological-sorted-values [ call ] each ;

