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

! #drop
M: #drop can-kill? ( literal node -- ? ) 2drop t ;

! #call
: (kill-shuffle) ( word -- map )
    {{
        [[ dup {{ }} ]]
        [[ drop {{ }} ]]
        [[ swap {{ }} ]]
        [[ over
            {{
                [[ { f t } dup  ]]
            }}
        ]]
        [[ pick
            {{
                [[ { f f t } over ]]
                [[ { f t f } over ]]
                [[ { f t t } dup  ]]
            }}
        ]]
        [[ >r {{ }} ]]
        [[ r> {{ }} ]]
    }} hash ;

M: #call can-kill? ( literal node -- ? )
    dup node-param (kill-shuffle) >r delegate can-kill? r> or ;

: kill-mask ( killing node -- mask )
    dup node-param \ r> = [ node-in-r ] [ node-in-d ] ifte
    [ swap memq? ] map-with ;

: lookup-mask ( mask word -- word )
    over [ ] contains? [ (kill-shuffle) hash ] [ nip ] ifte ;

: kill-shuffle ( literals node -- )
    #! If certain values passing through a stack op are being
    #! killed, the stack op can be reduced, in extreme cases
    #! to a no-op.
    [ [ kill-mask ] keep node-param lookup-mask ] keep
    set-node-param ;

M: #call kill-node* ( literals node -- )
    dup node-param (kill-shuffle)
    [ kill-shuffle ] [ 2drop ] ifte ;

! #call-label
M: #call-label can-kill? ( literal node -- ? ) 2drop t ;

! #values
M: #values can-kill? ( literal node -- ? ) 2drop t ;

! #merge
M: #merge can-kill? ( literal node -- ? ) 2drop t ;

! #entry
M: #entry can-kill? ( literal node -- ? ) 2drop t ;
