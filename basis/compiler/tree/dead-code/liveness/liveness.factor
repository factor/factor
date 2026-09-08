! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.tree compiler.tree.combinators
compiler.tree.def-use compiler.utilities kernel math
namespaces sequences stack-checker.branches ;
IN: compiler.tree.dead-code.liveness

SYMBOL: work-list

SYMBOL: live-values

: live-value? ( value -- ? ) live-values get at ;

: look-at-value ( value -- )
    dup live-values get key? [ drop ] [
        dup live-values get conjoin
        work-list get push
    ] if ;

: look-at-values ( values -- ) [ look-at-value ] each ;

: look-at-inputs ( node -- ) in-d>> look-at-values ;

: init-dead-code ( -- )
    V{ } clone work-list namespaces:set
    H{ { +bottom+ f } } clone live-values namespaces:set ;

GENERIC: mark-live-values* ( node -- )

: mark-live-values ( nodes -- nodes )
    dup [ mark-live-values* ] each-node ; inline

M: node mark-live-values* drop ;

GENERIC: compute-live-values* ( value node -- )

M: node compute-live-values* 2drop ;

: iterate-live-values ( value -- )
    dup defined-by compute-live-values* ;

: compute-live-values ( -- )
    ! Values are marked when queued, so each is processed once. Keep the
    ! original FIFO order without a second hash table or linked-list nodes.
    0 work-list get [ 2dup length < ] [
        2dup nth iterate-live-values [ 1 + ] dip
    ] while nip delete-all ;

GENERIC: remove-dead-code* ( node -- node' )

M: node remove-dead-code* ;

: (remove-dead-code) ( nodes -- nodes' )
    [ remove-dead-code* ] map-flat ;
