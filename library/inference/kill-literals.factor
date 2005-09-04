! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists
matrices namespaces sequences vectors ;

GENERIC: literals* ( node -- )

: literals ( node -- seq )
    [ [ literals* ] each-node ] { } make ;

GENERIC: can-kill? ( literal node -- ? )

: kill-set ( node -- list )
    #! Push a list of literals that may be killed in the IR.
    dup literals [
        swap [ can-kill? ] all-nodes-with?
    ] subset-with ;

: remove-values ( values node -- )
    2dup [ node-in-d seq-diff ] keep set-node-in-d
    2dup [ node-out-d seq-diff ] keep set-node-out-d
    2dup [ node-in-r seq-diff ] keep set-node-in-r
    [ node-out-r seq-diff ] keep set-node-out-r ;

GENERIC: kill-node* ( literals node -- )

M: node kill-node* ( literals node -- ) 2drop ;

: kill-node ( literals node -- )
    [ 2dup kill-node* remove-values ] each-node-with ;

! Generic nodes
M: node literals* ( node -- ) drop ;

M: node can-kill? ( literal node -- ? ) uses-value? not ;

! #push
M: #push literals* ( node -- )
    node-out-d % ;

M: #push can-kill? ( literal node -- ? ) 2drop t ;

M: #push kill-node* ( literals node -- )
    [ node-out-d seq-diff ] keep set-node-out-d ;

! #shuffle
M: #shuffle can-kill? ( literal node -- ? ) 2drop t ;

! #call-label
M: #call-label can-kill? ( literal node -- ? ) 2drop t ;

! #values
M: #values can-kill? ( literal node -- ? ) 2drop t ;

! #merge
M: #merge can-kill? ( literal node -- ? ) 2drop t ;

! #entry
M: #entry can-kill? ( literal node -- ? ) 2drop t ;
