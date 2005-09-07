! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists
matrices namespaces sequences vectors ;

GENERIC: literals* ( node -- seq )

: literals ( node -- seq )
    [ [ literals* % ] each-node ] { } make ;

GENERIC: can-kill* ( literal node -- ? )

: can-kill? ( literals node -- ? )
    dup [
        2dup can-kill* [
            node-successor can-kill?
        ] [
            2drop f
        ] ifte
    ] [
        2drop t
    ] ifte ;

: kill-set ( node -- list )
    #! Push a list of literals that may be killed in the IR.
    dup literals [ swap can-kill? ] subset-with ;

: remove-values ( values node -- )
    2dup [ node-in-d seq-diff ] keep set-node-in-d
    2dup [ node-out-d seq-diff ] keep set-node-out-d
    2dup [ node-in-r seq-diff ] keep set-node-in-r
    [ node-out-r seq-diff ] keep set-node-out-r ;

: kill-node ( literals node -- )
    [ remove-values ] each-node-with ;

! Generic nodes
M: node literals* ( node -- ) drop { } ;

M: node can-kill* ( literal node -- ? ) uses-value? not ;

! #push
M: #push literals* ( node -- ) node-out-d ;

M: #push can-kill* ( literal node -- ? ) 2drop t ;

! #shuffle
M: #shuffle can-kill* ( literal node -- ? ) 2drop t ;

! #call-label
M: #call-label can-kill* ( literal node -- ? ) 2drop t ;

! #merge
M: #merge can-kill* ( literal node -- ? ) 2drop t ;

! #entry
M: #entry can-kill* ( literal node -- ? ) 2drop t ;

! #return
SYMBOL: branch-returns

M: #return can-kill* ( literal node -- ? )
    #! Values returned by local labels can be killed.
    dup node-param [
        dupd uses-value? [
            branch-returns get
            [ memq? ] subset-with
            [ [ eq? ] monotonic? ] all?
        ] [
            drop t
        ] ifte
    ] [
        delegate can-kill*
    ] ifte ;

: branch-values ( branches -- )
    [ last-node node-in-d ] map
    unify-lengths flip branch-returns set ;

: can-kill-branches? ( literal node -- ? )
    #! Check if the literal appears in either branch. This
    #! assumes that the last element of each branch is a #return
    #! node.
    2dup uses-value? [
        2drop f
    ] [
        [
            node-children dup branch-values
            [ can-kill? ] all-with?
        ] with-scope
    ] ifte ;

! #ifte
M: #ifte can-kill* ( literal node -- ? )
    can-kill-branches? ;

! #dispatch
M: #dispatch can-kill* ( literal node -- ? )
    can-kill-branches? ;

! #label
M: #label can-kill* ( literal node -- ? )
    node-child can-kill? ;
