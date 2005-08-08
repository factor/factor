! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists
matrices namespaces sequences vectors ;

! We use the recursive-state variable here, to track nested
! label scopes, to prevent infinite loops when inlining
! recursive methods.

GENERIC: optimize-node* ( node -- node )

GENERIC: optimize-children

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

M: node optimize-children ( node -- )
    f swap [
        node-children [ optimize-node swap >r or r> ] map
    ] keep set-node-children ;

: optimize-loop ( dataflow -- dataflow )
    recursive-state off
    dup kill-set over kill-node
    dup infer-classes
    optimize-node [ optimize-loop ] when ;

: optimize ( dataflow -- dataflow )
    [
        dup solve-recursion
        optimize-loop
    ] with-scope ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] ifte ;
    inline

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t )
    drop t ;

! #push
M: #push optimize-node* ( node -- node/t )
    [ node-out-d empty? ] prune-if ;

! #drop
M: #drop optimize-node*  ( node -- node/t )
    [ node-in-d empty? ] prune-if ;

! #call
: flip-branches ( #ifte -- )
    dup node-children 2unseq swap 2vector swap set-node-children ;

! #label
: optimize-label ( node -- node )
    dup node-param recursive-state [ cons ] change
    delegate optimize-children
    recursive-state [ cdr ] change ;

M: #label optimize-children optimize-label ;

M: #simple-label optimize-children optimize-label ;

! #ifte
: static-branch? ( node -- lit ? )
    node-in-d first dup literal? ;

: static-branch ( conditional n -- node )
    >r [ drop-inputs ] keep r>
    over node-children nth
    over node-successor over last-node set-node-successor
    pick set-node-successor drop ;

M: #ifte optimize-node* ( node -- node )
    dup static-branch?
    [ literal-value 0 1 ? static-branch ] [ 2drop t ] ifte ;

! #values
: values/merge ( #values #merge -- new old )
    >r >r node-in-d r> node-in-d unify-length r> ;

: post-split ( #values -- node )
    #! If a #values is followed by a #merge, we need to replace
    #! meet values after the merge with their branch value in
    #! #values.
    dup node-successor dup node-successor
    values/merge [ subst-values ] keep ;

M: #values optimize-node* ( node -- node ? )
    dup node-successor #merge? [ post-split ] [ drop t ] ifte ;
