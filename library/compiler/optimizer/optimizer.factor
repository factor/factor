! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference io kernel math
namespaces sequences test vectors ;

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t )

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t eq?
    [ drop f ] [ nip keep-optimizing t or ] if ;

: optimize-node ( node -- node )
    [
        keep-optimizing [ optimizer-changed on ] when
    ] map-nodes ;

: optimize ( node -- node )
    dup kill-values dup infer-classes [
        optimizer-changed off
        optimize-node
        optimizer-changed get
    ] with-node-iterator [ optimize ] when ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] if ;
    inline

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t ) drop t ;

! #shuffle
M: #shuffle optimize-node*  ( node -- node/t )
    [ node-values empty? ] prune-if ;

! #push
M: #push optimize-node*  ( node -- node/t )
    [ node-out-d empty? ] prune-if ;

! #return
M: #return optimize-node* ( node -- node/t )
    node-successor [ node-successor ] [ t ] if* ;

! Some utilities for splicing in dataflow IR subtrees
: post-inline ( #return/#values #call/#merge -- )
    [
        >r node-in-d r> node-out-d 2array unify-lengths first2
    ] keep subst-values ;

: ?hash-union ( hash/f hash -- hash )
    over [ hash-union ] [ nip ] if ;

: add-node-literals ( hash node -- )
    [ node-literals ?hash-union ] keep set-node-literals ;

: add-node-classes ( hash node -- )
    [ node-classes ?hash-union ] keep set-node-classes ;

: (subst-classes) ( literals classes node -- )
    dup [
        3dup [ add-node-classes ] keep add-node-literals
        node-successor (subst-classes)
    ] [
        3drop
    ] if ;

: subst-classes ( #return/#values #call/#merge -- )
    >r dup node-literals swap node-classes r> (subst-classes) ;

: subst-node ( old new -- )
    #! The last node of 'new' becomes 'old', then values are
    #! substituted. A subsequent optimizer phase kills the
    #! last node of 'new' and the first node of 'old'.
    last-node 2dup swap 2dup post-inline subst-classes
    set-node-successor ;

! Constant branch folding
: node-value-literal? ( node value -- ? )
    dup value?
    [ 2drop t ] [ swap node-literals ?hash* nip ] if ;

: node-value-literal ( node value -- obj )
    dup value?
    [ nip value-literal ] [ swap node-literals ?hash ] if ;

: fold-branch ( node branch# -- node )
    over drop-inputs >r
    >r dup node-successor r> rot node-children nth
    [ subst-node ] keep r> [ set-node-successor ] keep ;

! #if
M: #if optimize-node* ( node -- node/t )
    dup dup node-in-d first 2dup node-value-literal? [
        node-value-literal 0 1 ? fold-branch
    ] [
        3drop t
    ] if ;

! #dispatch
M: #dispatch optimize-node* ( node -- node/t )
    dup dup node-in-d first 2dup node-value-literal? [
        node-value-literal fold-branch
    ] [
        3drop t
    ] if ;
