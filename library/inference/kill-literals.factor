! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists
matrices namespaces sequences vectors ;

GENERIC: literals* ( node -- )

: literals ( node -- seq )
    [ [ literals* ] each-node ] make-vector ;

GENERIC: can-kill* ( literal node -- ? )

: can-kill? ( literal node -- ? )
    #! Return false if the literal appears in any node in the
    #! list.
    dup [
        2dup can-kill*
        [ node-successor can-kill? ] [ 2drop f ] ifte
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

GENERIC: kill-node* ( literals node -- )

M: node kill-node* ( literals node -- ) 2drop ;

: kill-node ( literals node -- )
    [ 2dup kill-node* remove-values ] each-node-with ;

! Generic nodes
M: node literals* ( node -- ) drop ;

M: node can-kill* ( literal node -- ? ) uses-value? not ;

! #push
M: #push literals* ( node -- )
    node-out-d % ;

M: #push can-kill* ( literal node -- ? )
    2drop t ;

M: #push kill-node* ( literals node -- )
    [ node-out-d seq-diff ] keep set-node-out-d ;

! #drop
M: #drop can-kill* ( literal node -- ? )
    2drop t ;

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

M: #call can-kill* ( literal node -- ? )
    dup node-param (kill-shuffle) >r delegate can-kill* r> or ;

: kill-mask ( killing node -- mask )
    dup node-param \ r> = [ node-in-r ] [ node-in-d ] ifte
    [ swap memq? ] map-with ;

: lookup-mask ( mask word -- word )
    over disj [ (kill-shuffle) hash ] [ nip ] ifte ;

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
M: #call-label can-kill* ( literal node -- ? )
     2drop t ;

! #label
M: #label can-kill* ( literal node -- ? )
    node-children first can-kill? ;

M: #simple-label can-kill* ( literal node -- ? )
    node-children first can-kill? ;

! #ifte
SYMBOL: branch-returns

: branch-values ( branches -- )
    [ last-node node-in-d ] map
    unify-lengths flip branch-returns set ;

: can-kill-branches? ( literal node -- ? )
    #! Check if the literal appears in either branch. This
    #! assumes that the last element of each branch is a #values
    #! node.
    2dup uses-value? [
        2drop f
    ] [
        [
            node-children dup branch-values
            [ can-kill? ] all-with?
        ] with-scope
    ] ifte ;

M: #ifte can-kill* ( literal node -- ? )
    can-kill-branches? ;

! #dispatch
M: #dispatch can-kill* ( literal node -- ? )
    can-kill-branches? ;

! #values
M: #values can-kill* ( literal node -- ? )
    dupd uses-value? [
        branch-returns get
        [ memq? ] subset-with
        [ [ eq? ] every? ] all?
    ] [
        drop t
    ] ifte ;

! #merge
M: #merge can-kill* ( literal node -- ? ) 2drop t ;

! #entry
M: #entry can-kill* ( literal node -- ? ) 2drop t ;
