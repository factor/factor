! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists matrices
namespaces sequences vectors ;

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
        2dup can-kill*
        [ node-successor can-kill? ] [ 2drop f ] ifte
    ] [
        2drop t
    ] ifte ;

: kill-set ( node -- list )
    #! Push a list of literals that may be killed in the IR.
    dup literals [ swap can-kill? ] subset-with ;

: remove-value ( value node -- )
    2dup [ node-in-d seq-diff ] keep set-node-in-d
    2dup [ node-out-d seq-diff ] keep set-node-out-d
    2dup [ node-in-r seq-diff ] keep set-node-in-r
    [ node-out-r seq-diff ] keep set-node-out-r ;

GENERIC: kill-node* ( literals node -- )

M: node kill-node* ( literals node -- ) 2drop ;

DEFER: kill-node

: kill-children ( literals node -- )
    node-children [ kill-node ] each-with ;

: kill-node ( literals node -- )
    dup [
        2dup kill-children
        2dup kill-node*
        2dup remove-value
        node-successor kill-node
    ] [
        2drop
    ] ifte ;

GENERIC: optimize-node* ( node -- node )

DEFER: optimize-node ( node -- node/t )

: optimize-children ( node -- )
    f swap [
        node-children [ optimize-node swap >r or r> ] map
    ] keep set-node-children ;

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t =
    [ drop f ] [ nip keep-optimizing t or ] ifte ;

: optimize-node ( node -- node ? )
    #! Outputs t if any changes were made.
    keep-optimizing >r dup [
        dup optimize-children >r
        dup node-successor optimize-node >r
        over set-node-successor r> r> r> or or
    ] [ r> ] ifte ;

: optimize ( dataflow -- dataflow )
    #! Remove redundant literals from the IR. The original IR
    #! is destructively modified.
    dup kill-set over kill-node
    dup infer-classes
    optimize-node
    [ optimize ] when ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] ifte ;
    inline

! Generic nodes
M: node literals* ( node -- )
    node-children [ literals, ] each ;

M: f can-kill* ( literal node -- ? )
    2drop t ;

M: node can-kill* ( literal node -- ? )
    uses-value? not ;

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
    [ node-out-d seq-diff ] keep set-node-out-d ;

M: #push optimize-node* ( node -- node/t )
    [ node-out-d empty? ] prune-if ;

! #drop
M: #drop can-kill* ( literal node -- ? )
    2drop t ;

M: #drop optimize-node*  ( node -- node/t )
    [ node-in-d empty? ] prune-if ;

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

: optimize-not? ( #call -- ? )
    dup node-param \ not =
    [ node-successor #ifte? ] [ drop f ] ifte ;

: flip-branches ( #ifte -- )
    dup node-children 2unseq swap 2vector swap set-node-children ;

! #call-label
M: #call-label can-kill* ( literal node -- ? )
     2drop t ;

! #label
M: #label can-kill* ( literal node -- ? )
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
M: #values can-kill* ( literal node -- ? )
    dupd uses-value? [
        branch-returns get
        [ memq? ] subset-with
        [ [ eq? ] every? ] all?
    ] [
        drop t
    ] ifte ;

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

: values/merge ( #values #merge -- new old )
    >r >r node-in-d r> node-in-d 2vector unify-lengths 2unseq r> ;

: post-split ( #values -- node )
    #! If a #values is followed by a #merge, we need to replace
    #! meet values after the merge with their branch value in
    #! #values.
    dup node-successor dup node-successor
    values/merge [ subst-values ] keep ;

M: #values optimize-node* ( node -- node ? )
    dup node-successor #merge? [ post-split ] [ drop t ] ifte ;

! #merge
M: #merge can-kill* ( literal node -- ? ) 2drop t ;
