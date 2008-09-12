! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: assocs digraphs kernel namespaces sequences ;
IN: triggers

: triggers ( -- triggers )
    \ triggers global [ drop H{ } clone ] cache ;

: trigger-graph ( trigger -- graph )
    triggers [ drop <digraph> ] cache ;

: reset-trigger ( trigger -- )
    <digraph> swap triggers set-at ;

: add-trigger ( key quot trigger -- )
    #! trigger should be a symbol. Note that symbols with the same name but
    #! different vocab are not equal
    trigger-graph add-vertex ; 

: before ( key1 key2 trigger -- )
    trigger-graph add-edge ;

: after ( key1 key2 trigger -- )
    swapd before ;

: call-trigger ( trigger -- )
    trigger-graph topological-sorted-values [ call ] each ;

