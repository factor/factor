! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference io kernel math
namespaces sequences vectors class-inference words errors ;

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t )

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t eq?
    [ drop f ] [ nip keep-optimizing t or ] if ;

: optimize-node ( node -- node )
    [
        keep-optimizing [ optimizer-changed on ] when
    ] map-nodes ;

: optimize-1 ( node -- node ? )
    [
        dup compute-def-use
        dup kill-values
        dup infer-classes
        optimizer-changed off
        optimize-node
        optimizer-changed get
    ] with-node-iterator ;

: optimize ( node -- node )
    optimize-1 [ optimize ] when ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] if ;
    inline

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* drop t ;

! #shuffle
M: #shuffle optimize-node* 
    [ node-values empty? ] prune-if ;

! #push
M: #push optimize-node* 
    [ node-out-d empty? ] prune-if ;

! #return
M: #return optimize-node*
    node-successor [ node-successor ] [ t ] if* ;

! #values
M: #values optimize-node*
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

GENERIC: remember-method* ( method-spec node -- )

M: #call remember-method*
    [ node-history ?push ] keep set-node-history ;

M: node remember-method*
    2drop ;

: remember-method ( method-spec node -- )
    over [ [ remember-method* ] each-node-with ] [ 2drop ] if ;

: (splice-method) ( #call method-spec quot -- node )
    #! Must remember the method before splicing in, otherwise
    #! the rest of the IR will also remember the method
    pick node-in-d dataflow-with
    [ remember-method ] keep
    [ infer-classes/node ] 2keep
    [ subst-node ] keep ;

: splice-quot ( #call quot -- node ) f swap (splice-method) ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone in-node <#shuffle> ;

! Constant branch folding
: fold-branch ( node branch# -- node )
    over drop-inputs >r
    over node-children nth
    swap node-successor over subst-node
    r> [ set-node-successor ] keep ;

! #if
: known-boolean-value? ( node value -- value ? )
    2dup node-literal? [
        node-literal t
    ] [
        node-class {
            { [ dup null class< ] [ drop f f ] }
            { [ dup general-t class< ] [ drop t t ] }
            { [ dup \ f class< ] [ drop f t ] }
            { [ t ] [ drop f f ] }
        } cond
    ] if ;

M: #if optimize-node*
    dup dup node-in-d first known-boolean-value?
    [ 0 1 ? fold-branch ] [ 2drop t ] if ;

! #dispatch
M: #dispatch optimize-node*
    dup dup node-in-d first 2dup node-literal? [
        node-literal fold-branch
    ] [
        3drop t
    ] if ;

! #call
: splice-method ( #call method-spec/t quot/t -- node/t )
    #! t indicates failure
    {
        { [ dup t eq? ] [ 3drop t ] }
        { [ pick pick swap node-history member? ] [ 3drop t ] }
        { [ t ] [ (splice-method) ] }
    } cond ;

! Single dispatch method inlining optimization
: already-inlined? ( node -- ? )
    #! Was this node inlined from definition of 'word'?
    dup node-param swap node-history memq? ;

: specific-method ( class word -- class ) order min-class ;

: dispatch# ( word -- n ) "combination" word-prop first ;

: dispatching-class ( node word -- class )
    [ dispatch# node-class# ] keep specific-method ;

: will-inline-method ( node word -- method-spec/t quot/t )
    #! t indicates failure
    tuck dispatching-class dup [
        swap [ 2array ] 2keep
        method method-def
    ] [
        2drop t t
    ] if ;

: inline-standard-method ( node word -- node )
    dupd will-inline-method splice-method ;

! Partial dispatch of 2generic words
: math-both-known? ( word left right -- ? )
    math-class-max swap specific-method ;

: will-inline-math-method ( word left right -- method-spec/t quot/t )
    #! t indicates failure
    3dup math-both-known?
    [ [ 3array ] 3keep math-method ] [ 3drop t t ] if ;

: inline-math-method ( #call word -- node )
    over 1 node-class# pick 0 node-class#
    will-inline-math-method splice-method ;

: inline-method ( #call -- node )
    dup node-param {
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup 2generic? ] [ inline-math-method ] }
        { [ t ] [ 2drop t ] }
    } cond ;

! Resolve type checks at compile time where possible
: comparable? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r classes-intersect? not r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r 0 node-class# r> comparable?
    ] [
        2drop f
    ] if ;

: literal-quot ( node literals -- quot )
    #! Outputs a quotation which drops the node's inputs, and
    #! pushes some literals.
    >r node-in-d length \ drop <array>
    r> [ literalize ] map append >quotation ;

: inline-literals ( node literals -- node )
    #! Make #shuffle -> #push -> #return -> successor
    dupd literal-quot splice-quot ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup 0 node-class# r> class< 1array inline-literals ;

: optimizer-hooks ( node -- conditions )
    node-param "optimizer-hooks" word-prop ;

: optimize-hooks ( node -- node/t )
    dup optimizer-hooks cond ;

: define-optimizers ( word optimizers -- )
    { [ t ] [ drop t ] } add "optimizer-hooks" set-word-prop ;

: partial-eval? ( #call -- ? )
    dup node-param "foldable" word-prop [
        dup node-in-d [ node-literal? ] all-with?
    ] [
        drop f
    ] if ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [ node-literal ] map-with ;

: partial-eval ( #call -- node )
    dup literal-in-d over node-param
    [ with-datastack ] catch
    [ 3drop t ] [ inline-literals ] if ;

: define-identities ( words identities -- )
    swap [ swap "identities" set-word-prop ] each-with ;

: find-identity ( node -- quot )
    dup node-param "identities" word-prop
    [ first in-d-match? ] assoc* ;

: apply-identities ( node -- node/f )
    dup find-identity dup [ splice-quot ] [ 2drop f ] if ;

: optimistic-inline? ( #call -- ? )
    dup node-param "specializer" word-prop [
        dup node-in-d [
            node-class types length 1 number=
        ] all-with?
    ] [
        drop f
    ] if ;

: optimistic-inline ( #call -- node )
    dup node-param word-def splice-quot ;

M: #call optimize-node*
    {
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup find-identity ] [ apply-identities ] }
        { [ dup optimizer-hooks ] [ optimize-hooks ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ dup optimistic-inline? ] [ optimistic-inline ] }
        { [ t ] [ inline-method ] }
    } cond ;
