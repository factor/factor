! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: hashtables inference kernel lists namespaces sequences ;

! The optimizer transforms dataflow IR to dataflow IR. Currently
! it removes literals that are eventually dropped, and never
! arise as inputs to any other type of function. Such 'dead'
! literals arise when combinators are inlined and quotations are
! lifted to their call sites.

GENERIC: literals* ( node -- )

: literals, ( node -- )
    [ dup literals* node-successor literals, ] when* ;

: literals ( node -- list )
    [ literals, ] make-list ;

GENERIC: can-kill* ( literal node -- ? )

: can-kill? ( literal node -- ? )
    #! Return false if the literal appears in any node in the
    #! list.
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

GENERIC: kill-node* ( literals node -- )

DEFER: kill-node

: kill-children ( literals node -- )
    node-children [ kill-node ] each-with ;

: kill-node ( literals node -- )
    dup [
        2dup kill-children
        2dup kill-node* node-successor kill-node
    ] [
        2drop
    ] ifte ;

GENERIC: useless-node? ( node -- ? )

DEFER: prune-nodes

: prune-children ( node -- )
    [ node-children [ prune-nodes ] map ] keep
    set-node-children ;

: (prune-nodes) ( node -- )
    [
        dup prune-children
        dup node-successor dup useless-node? [
            node-successor over set-node-successor
        ] [
            nip
        ] ifte (prune-nodes)
    ] when* ;

: prune-nodes ( node -- node )
    dup useless-node? [
        node-successor prune-nodes
    ] [
        [ (prune-nodes) ] keep
    ] ifte ;

: optimize ( dataflow -- dataflow )
    #! Remove redundant literals from the IR. The original IR
    #! is destructively modified.
    dup kill-set over kill-node prune-nodes ;

! Generic nodes
M: node literals* ( node -- )
    node-children [ literals, ] each ;

M: f can-kill* ( literal node -- ? )
    2drop t ;

M: node can-kill* ( literal node -- ? )
    2dup consumes-literal? >r produces-literal? r> or not ;

M: node kill-node* ( literals node -- )
    2drop ;

M: f useless-node? ( node -- ? )
    drop f ;

M: node useless-node? ( node -- ? )
    drop f ;

! #push
M: #push literals* ( node -- )
    node-out-d % ;

M: #push can-kill* ( literal node -- ? )
    2drop t ;

M: #push kill-node* ( literals node -- )
    [ node-out-d diffq ] keep set-node-out-d ;

M: #push useless-node? ( node -- ? )
    node-out-d empty? ;

! #drop
M: #drop can-kill* ( literal node -- ? )
     2drop t ;

M: #drop kill-node* ( literals node -- )
    [ node-in-d diffq ] keep set-node-in-d ;

M: #drop useless-node? ( node -- ? )
    node-in-d empty? ;

! #call
M: #call can-kill* ( literal node -- ? )
    nip node-param {{
        [[ dup t ]]
        [[ drop t ]]
        [[ swap t ]]
        [[ over t ]]
        [[ pick t ]] 
        [[ >r t ]]
        [[ r> t ]]
    }} hash ;

: kill-mask ( killing inputs -- mask )
    [ swap memq? ] map-with ;

: (kill-shuffle) ( word -- map )
    {{
        [[ over
            {{
                [[ [ f t ] dup  ]]
            }}
        ]]
        [[ pick
            {{
                [[ [ f f t ] over ]]
                [[ [ f t f ] over ]]
                [[ [ f t t ] dup  ]]
            }}
        ]]
        [[ swap {{ }} ]]
        [[ dup {{ }} ]]
        [[ >r {{ }} ]]
        [[ r> {{ }} ]]
    }} hash ;

: lookup-mask ( mask word -- word )
    over [ not ] all? [ nip ] [ (kill-shuffle) hash ] ifte ;

: kill-shuffle ( literals node -- )
    #! If certain values passing through a stack op are being
    #! killed, the stack op can be reduced, in extreme cases
    #! to a no-op.
    [ [ node-in-d kill-mask ] keep node-param lookup-mask ] keep
    set-node-param ;

M: #call kill-node* ( literals node -- )
    dup node-param (kill-shuffle)
    [ kill-shuffle ] [ 2drop ] ifte ;

M: #call useless-node? ( node -- ? )
    node-param not ;

! #call-label
M: #call-label can-kill* ( literal node -- ? )
     2drop t ;

! #label
M: #label can-kill* ( literal node -- ? )
    node-children car can-kill? ;

! #values
SYMBOL: branch-returns

M: #values can-kill* ( literal node -- ? )
    dupd consumes-literal? [
        branch-returns get
        [ memq? ] subset-with
        [ [ eq? ] fiber? ] all?
    ] [
        drop t
    ] ifte ;

: branch-values ( branches -- )
    [ last-node node-in-d >list ] map
    unify-lengths seq-transpose branch-returns set ;

: can-kill-branches? ( literal node -- ? )
    #! Check if the literal appears in either branch. This
    #! assumes that the last element of each branch is a #values
    #! node.
    2dup consumes-literal? [
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
