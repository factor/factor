! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend io kernel math namespaces
sequences vectors words quotations hashtables combinators
classes generic.math continuations optimizer.def-use
optimizer.pattern-match generic.standard ;
IN: optimizer.backend

SYMBOL: class-substitutions

SYMBOL: literal-substitutions

SYMBOL: value-substitutions

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t changed? )

: ?union ( hash/f hash -- hash )
    over [ union ] [ nip ] if ;

: add-node-literals ( hash node -- )
    over assoc-empty? [
        2drop
    ] [
        [ node-literals ?union ] keep set-node-literals
    ] if ;

: add-node-classes ( hash node -- )
    over assoc-empty? [
        2drop
    ] [
        [ node-classes ?union ] keep set-node-classes
    ] if ;

: substitute-values ( assoc node -- )
    over assoc-empty? [
        2drop
    ] [
        2dup node-in-d substitute
        2dup node-in-r substitute
        2dup node-out-d substitute
        node-out-r substitute
    ] if ;

: perform-substitutions ( node -- )
    class-substitutions get over add-node-classes
    literal-substitutions get over add-node-literals
    value-substitutions get swap substitute-values ;

DEFER: optimize-nodes

: optimize-children ( node -- )
    [
        dup node-children dup [
            [ optimize-nodes ] map swap set-node-children
        ] [
            2drop
        ] if
    ] when* ;

: optimize-node ( node -- node )
    dup [
        dup perform-substitutions
        dup optimize-node* [
            nip optimizer-changed on optimize-node
        ] [
            dup t eq? [
                drop dup optimize-children
            ] [
                nip optimize-node
            ] if
        ] if
    ] when ;

M: f set-node-successor 2drop ;

: (optimize-nodes) ( prev node -- )
    optimize-node [
        dup rot set-node-successor
        dup node-successor (optimize-nodes)
    ] [
        f swap set-node-successor
    ] if* ;

: optimize-nodes ( node -- newnode )
    [
        class-substitutions [ clone ] change
        literal-substitutions [ clone ] change
        dup [
            optimize-node
            dup dup node-successor (optimize-nodes)
        ] when optimizer-changed get
    ] with-scope optimizer-changed set ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor t ] [ r> drop t f ] if ;
    inline

! Generic nodes
M: node optimize-node* drop t f ;

M: #shuffle optimize-node* 
    [
        dup node-in-d empty? swap node-out-d empty? and
    ] prune-if ;

M: #push optimize-node* 
    [ node-out-d empty? ] prune-if ;

: cleanup-inlining ( node -- newnode changed? )
    node-successor [ node-successor t ] [ t f ] if* ;

! #return
M: #return optimize-node* cleanup-inlining ;

! #values
M: #values optimize-node* cleanup-inlining ;

! Some utilities for splicing in dataflow IR subtrees
: follow ( key assoc -- value )
    2dup at* [ swap follow nip ] [ 2drop ] if ;

: union* ( assoc1 assoc2 -- assoc )
    union [ keys ] keep
    [ dupd follow ] curry
    H{ } map>assoc ;

: update* ( assoc1 assoc2 -- )
    #! Not very efficient.
    dupd union* update ;

: post-inline ( #call/#merge #return/#values -- assoc )
    >r node-out-d r> node-in-d 2array unify-lengths flip
    [ = not ] assoc-subset >hashtable ;

: substitute-def-use ( node -- )
    #! As a first approximation, we take all the values used
    #! by the set of new nodes, and push a 't' on their
    #! def-use list here. We could perform a full graph
    #! substitution, but we don't need to, because the next
    #! optimizer iteration will do that. We just need a minimal
    #! degree of accuracy; the new values should be marked as
    #! having _some_ usage, so that flushing doesn't erronously
    #! flush them away.
    [ compute-def-use def-use get keys ] with-scope
    def-use get [ [ t swap ?push ] change-at ] curry each ;

: substitute-node ( old new -- )
    #! The last node of 'new' becomes 'old', then values are
    #! substituted. A subsequent optimizer phase kills the
    #! last node of 'new' and the first node of 'old'.
    dup substitute-def-use
    last-node
    class-substitutions get over node-classes update
    literal-substitutions get over node-literals update
    2dup post-inline value-substitutions get swap update*
    set-node-successor ;

GENERIC: remember-method* ( method-spec node -- )

M: #call remember-method*
    [ node-history ?push ] keep set-node-history ;

M: node remember-method*
    2drop ;

: remember-method ( method-spec node -- )
    swap dup
    [ [ swap remember-method* ] curry each-node ] [ 2drop ] if ;

: (splice-method) ( #call method-spec quot -- node )
    #! Must remember the method before splicing in, otherwise
    #! the rest of the IR will also remember the method
    pick node-in-d dataflow-with
    [ remember-method ] keep
    [ swap infer-classes/node ] 2keep
    [ substitute-node ] keep ;

: splice-quot ( #call quot -- node ) f swap (splice-method) ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone \ #shuffle in-node ;

! Constant branch folding
: fold-branch ( node branch# -- node )
    over drop-inputs >r
    over node-children nth
    swap node-successor over substitute-node
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
    [ 0 1 ? fold-branch t ] [ 2drop t f ] if ;

M: #dispatch optimize-node*
    dup dup node-in-d first 2dup node-literal? [
        node-literal fold-branch t
    ] [
        3drop t f
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

: node-class# ( node n -- class )
    over node-in-d <reversed> ?nth node-class ;

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

! Partial dispatch of math-generic words
: math-both-known? ( word left right -- ? )
    math-class-max swap specific-method ;

: will-inline-math-method ( word left right -- method-spec/t quot/t )
    #! t indicates failure
    3dup math-both-known?
    [ [ 3array ] 3keep math-method ] [ 3drop t t ] if ;

: inline-math-method ( #call word -- node )
    over node-input-classes first2
    will-inline-math-method splice-method ;

: inline-method ( #call -- node )
    dup node-param {
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup math-generic? ] [ inline-math-method ] }
        { [ t ] [ 2drop t ] }
    } cond ;

! Resolve type checks at compile time where possible
: comparable? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r classes-intersect? not r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r node-class-first r> comparable?
    ] [
        2drop f
    ] if ;

: literal-quot ( node literals -- quot )
    #! Outputs a quotation which drops the node's inputs, and
    #! pushes some literals.
    >r node-in-d length \ drop <repetition>
    r> [ literalize ] map append >quotation ;

: inline-literals ( node literals -- node )
    #! Make #shuffle -> #push -> #return -> successor
    dupd literal-quot splice-quot ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup node-class-first r> class< 1array inline-literals ;

: optimizer-hooks ( node -- conditions )
    node-param "optimizer-hooks" word-prop ;

: optimizer-hook ( node -- pair/f )
    dup optimizer-hooks [ first call ] find 2nip ;

: optimize-hook ( node -- )
    dup optimizer-hook second call ;

: define-optimizers ( word optimizers -- )
    "optimizer-hooks" set-word-prop ;

: flush-eval? ( #call -- ? )
    dup node-param "flushable" word-prop [
        node-out-d [ unused? ] all?
    ] [
        drop f
    ] if ;

: flush-eval ( #call -- node )
    dup node-out-d length f <repetition> inline-literals ;

: partial-eval? ( #call -- ? )
    dup node-param "foldable" word-prop [
        dup node-in-d [ node-literal? ] curry* all?
    ] [
        drop f
    ] if ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [ node-literal ] curry* map ;

: partial-eval ( #call -- node )
    dup literal-in-d over node-param 1quotation
    [ with-datastack ] catch
    [ 3drop t ] [ inline-literals ] if ;

: define-identities ( words identities -- )
    [ "identities" set-word-prop ] curry each ;

: find-identity ( node -- quot )
    [ node-param "identities" word-prop ] keep
    [ swap first in-d-match? ] curry find
    nip dup [ second ] when ;

: apply-identities ( node -- node/f )
    dup find-identity dup [ splice-quot ] [ 2drop f ] if ;

: optimistic-inline? ( #call -- ? )
    dup node-param "specializer" word-prop dup [
        >r node-input-classes r> length tail*
        [ types length 1 = ] all?
    ] [
        2drop f
    ] if ;

: optimistic-inline ( #call -- node )
    dup node-param word-def splice-quot ;

M: #call optimize-node*
    {
        { [ dup flush-eval? ] [ flush-eval ] }
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup find-identity ] [ apply-identities ] }
        { [ dup optimizer-hook ] [ optimize-hook ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ dup optimistic-inline? ] [ optimistic-inline ] }
        { [ t ] [ inline-method ] }
    } cond dup not ;
