! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists matrices
namespaces sequences vectors ;

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

GENERIC: optimize-node* ( node -- node )

DEFER: optimize-node ( node -- node/t )

: optimize-children ( node -- )
    dup node-children [ optimize-node ] map
    swap set-node-children ;

: keep-optimizing ( node -- node )
    dup optimize-node* dup t =
    [ drop ] [ nip keep-optimizing ] ifte ;

: optimize-node ( node -- node )
    keep-optimizing dup [
        dup optimize-children
        dup node-successor optimize-node over set-node-successor
    ] when ;

: optimize ( dataflow -- dataflow )
    #! Remove redundant literals from the IR. The original IR
    #! is destructively modified.
    dup kill-set over kill-node optimize-node ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] ifte ;

! Generic nodes
M: node literals* ( node -- )
    node-children [ literals, ] each ;

M: f can-kill* ( literal node -- ? )
    2drop t ;

M: node can-kill* ( literal node -- ? )
    2dup consumes-literal? >r produces-literal? r> or not ;

M: node kill-node* ( literals node -- )
    2drop ;

M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t )
    drop t ;

! #push
M: #push literals* ( node -- )
    node-out-d % ;

M: #push can-kill* ( literal node -- ? )
    2drop t ;

M: #push kill-node* ( literals node -- )
    [ node-out-d seq-diffq ] keep set-node-out-d ;

M: #push optimize-node* ( node -- node/t )
    [ node-out-d empty? ] prune-if ;

! #drop
M: #drop can-kill* ( literal node -- ? )
     2drop t ;

M: #drop kill-node* ( literals node -- )
    [ node-in-d seq-diffq ] keep set-node-in-d ;

M: #drop optimize-node*  ( node -- node/t )
    [ node-in-d empty? ] prune-if ;

! #call
M: #call can-kill* ( literal node -- ? )
    dup node-param {{
        [[ dup t ]]
        [[ drop t ]]
        [[ swap t ]]
        [[ over t ]]
        [[ pick t ]] 
        [[ >r t ]]
        [[ r> t ]]
    }} hash >r delegate can-kill* r> or ;

: kill-mask ( killing node -- mask )
    dup node-param \ r> = [ node-in-r ] [ node-in-d ] ifte
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

: optimize-not? ( #call -- ? )
    dup node-param \ not =
    [ node-successor #ifte? ] [ drop f ] ifte ;

: flip-branches ( #ifte -- )
    dup node-children 2unseq swap 2vector swap set-node-children ;

M: #call optimize-node* ( node -- node )
     dup optimize-not? [
         node-successor dup flip-branches
     ] [
         [ node-param not ] prune-if
     ] ifte ;

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
    [ last-node node-in-d ] map
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
: static-branch? ( node -- lit ? )
    node-in-d first dup safe-literal? ;

: static-branch ( conditional n -- node )
    >r [ node-in-d in-d-node <#drop> ] keep r>
    over node-children nth
    over node-successor over last-node set-node-successor
    pick set-node-successor drop ;

M: #ifte can-kill* ( literal node -- ? )
    can-kill-branches? ;

M: #ifte optimize-node* ( node -- node )
    dup static-branch?
    [ f swap value= 1 0 ? static-branch ] [ 2drop t ] ifte ;

! #dispatch
M: #dispatch can-kill* ( literal node -- ? )
    can-kill-branches? ;

! #values
: subst-values ( new old node -- )
    dup [
        3dup [ node-in-d subst ] keep set-node-in-d
        3dup [ node-in-r subst ] keep set-node-in-r
        3dup [ node-out-d subst ] keep set-node-out-d
        3dup [ node-out-r subst ] keep set-node-out-r
        node-successor subst-values
    ] [
        3drop
    ] ifte ;

: post-split ( #values -- node )
    #! If a #values is followed by a #merge, we need to replace
    #! meet values after the merge with their branch value in
    #! #values.
    dup node-successor dup node-successor
    >r >r node-in-d reverse-slice r> node-in-d reverse-slice r>
    [ subst-values ] keep ;

M: #values optimize-node* ( node -- node )
    dup node-successor #merge? [ post-split ] [ drop t ] ifte ;
