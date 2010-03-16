! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors namespaces assocs deques search-deques
dlists kernel sequences compiler.utilities words sets
stack-checker.branches compiler.tree compiler.tree.def-use
compiler.tree.combinators ;
FROM: namespaces => set ;
IN: compiler.tree.dead-code.liveness

SYMBOL: work-list

SYMBOL: live-values

: live-value? ( value -- ? ) live-values get at ;

: look-at-value ( values -- ) work-list get push-front ;

: look-at-values ( values -- ) work-list get push-all-front ;

: look-at-inputs ( node -- ) in-d>> look-at-values ;

: init-dead-code ( -- )
    <hashed-dlist> work-list set
    H{ { +bottom+ f } } clone live-values set ;

GENERIC: mark-live-values* ( node -- )

: mark-live-values ( nodes -- nodes )
    dup [ mark-live-values* ] each-node ; inline

M: node mark-live-values* drop ;

GENERIC: compute-live-values* ( value node -- )

M: node compute-live-values* 2drop ;

: iterate-live-values ( value -- )
    dup live-values get key? [
        drop
    ] [
        dup live-values get conjoin
        dup defined-by compute-live-values*
    ] if ;

: compute-live-values ( -- )
    work-list get [ iterate-live-values ] slurp-deque ;

GENERIC: remove-dead-code* ( node -- node' )

M: node remove-dead-code* ;

: (remove-dead-code) ( nodes -- nodes' )
    [ remove-dead-code* ] map-flat ;
