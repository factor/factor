! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes generic.math continuations optimizer.def-use
optimizer.pattern-match generic.standard optimizer.specializers ;
IN: optimizer.backend

SYMBOL: class-substitutions

SYMBOL: literal-substitutions

SYMBOL: value-substitutions

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t changed? )

: ?union ( assoc/f assoc -- hash )
    over [ union ] [ nip ] if ;

: add-node-literals ( assoc node -- )
    over assoc-empty? [
        2drop
    ] [
        [ node-literals ?union ] keep set-node-literals
    ] if ;

: add-node-classes ( assoc node -- )
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
    [ optimize-nodes ] change-children ;

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

: optimize-nodes ( node -- newnode )
    [
        class-substitutions [ clone ] change
        literal-substitutions [ clone ] change
        [ optimize-node ] transform-nodes
        optimizer-changed get
    ] with-scope optimizer-changed set ;

! Generic nodes
M: node optimize-node* drop t f ;

! Post-inlining cleanup
: follow ( key assoc -- value )
    2dup at* [ swap follow nip ] [ 2drop ] if ;

: union* ( assoc1 assoc2 -- assoc )
    union [ keys ] keep
    [ dupd follow ] curry
    H{ } map>assoc ;

: update* ( assoc1 assoc2 -- )
    #! Not very efficient.
    dupd union* update ;

: compute-value-substitutions ( #return/#values #call/#merge -- assoc )
    node-out-d swap node-in-d 2array unify-lengths flip
    [ = not ] assoc-subset >hashtable ;

: cleanup-inlining ( #return/#values -- newnode changed? )
    dup node-successor dup [
        class-substitutions get pick node-classes update
        literal-substitutions get pick node-literals update
        tuck compute-value-substitutions value-substitutions get swap update*
        node-successor t
    ] [
        2drop t f
    ] if ;

! #return
M: #return optimize-node* cleanup-inlining ;

! #values
M: #values optimize-node* cleanup-inlining ;

! Some utilities for splicing in dataflow IR subtrees
M: f set-node-successor 2drop ;

: splice-node ( old new -- )
    dup splice-def-use last-node set-node-successor ;

GENERIC: remember-method* ( method-spec node -- )

M: #call remember-method*
    [ node-history ?push ] keep set-node-history ;

M: node remember-method*
    2drop ;

: remember-method ( method-spec node -- )
    swap dup second +inlined+ depends-on
    [ swap remember-method* ] curry each-node ;

: (splice-method) ( #call method-spec quot -- node )
    #! Must remember the method before splicing in, otherwise
    #! the rest of the IR will also remember the method
    pick node-in-d dataflow-with
    [ remember-method ] keep
    [ swap infer-classes/node ] 2keep
    [ splice-node ] keep ;

: splice-quot ( #call quot -- node )
    over node-in-d dataflow-with
    [ swap infer-classes/node ] 2keep
    [ splice-node ] keep ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone \ #shuffle in-node ;

! Constant branch folding
: fold-branch ( node branch# -- node )
    over node-children nth
    swap node-successor over splice-node ;

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

: fold-if-branch? dup node-in-d first known-boolean-value? ;

: fold-if-branch ( node value -- node' )
    over drop-inputs >r
    0 1 ? fold-branch
    r> [ set-node-successor ] keep ;

: only-one ( seq -- elt/f )
    dup length 1 = [ first ] [ drop f ] if ;

: lift-throw-tail? ( #if -- tail/? )
    dup node-successor node-successor
    [ active-children only-one ] [ drop f ] if ;

: clone-node ( node -- newnode )
    clone dup [ clone ] modify-values ;

: detach-node-successor ( node -- successor )
    dup node-successor #terminate rot set-node-successor ;

: lift-branch ( #if node -- )
    >r detach-node-successor r> splice-node ;

M: #if optimize-node*
    dup fold-if-branch? [ fold-if-branch t ] [
        2drop t f
        ! drop dup lift-throw-tail? dup [
        !     dupd lift-branch t
        ! ] [
        !     2drop t f
        ! ] if
    ] if ;

: fold-dispatch-branch? dup node-in-d first tuck node-literal? ;

: fold-dispatch-branch ( node value -- node' )
    dupd node-literal
    over drop-inputs >r fold-branch r>
    [ set-node-successor ] keep ;

M: #dispatch optimize-node*
    dup fold-dispatch-branch? [
        fold-dispatch-branch t
    ] [
        2drop t f
    ] if ;

! #loop


! BEFORE:

!   #label -> C -> #return 1
!     |
!     -> #if -> #merge -> #return 2
!         |
!     --------
!     |      |
!     A      B
!     |      |
!  #values   |
!        #call-label
!            |
!            |
!         #values

! AFTER:

!    #label -> #terminate
!     |
!     -> #if -> #terminate
!         |
!     --------
!     |      |
!     A      B
!     |      |
!  #values   |
!     |  #call-label
!  #merge    |
!     |      |
!     C   #values
!     |
!  #return 1

: find-final-if ( node -- #if/f )
    dup [
        dup #if? [
            dup node-successor #tail? [
                node-successor find-final-if
            ] unless
        ] [
            node-successor find-final-if
        ] if
    ] when ;

: lift-loop-tail? ( #label -- tail/f )
    dup node-successor node-successor [
        dup node-param swap node-child find-final-if dup [
            node-children [ penultimate-node ] map
            [
                dup #call-label?
                [ node-param eq? not ] [ 2drop t ] if
            ] with subset only-one
        ] [ 2drop f ] if
    ] [ drop f ] if ;

! M: #loop optimize-node*
!     dup lift-loop-tail? dup [
!         last-node >r
!         dup detach-node-successor
!         over node-child find-final-if detach-node-successor
!         [ set-node-successor ] keep
!         r> set-node-successor
!         t
!     ] [
!         2drop t f
!     ] if ;

! #call
: splice-method ( #call method-spec/t quot/t -- node/t )
    #! t indicates failure
    {
        { [ dup t eq? ] [ 3drop t ] }
        { [ 2over swap node-history member? ] [ 3drop t ] }
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

! A heuristic to avoid excessive inlining
DEFER: (flat-length)

: word-flat-length ( word -- n )
    dup get over inline? not or
    [ drop 1 ] [ dup dup set word-def (flat-length) ] if ;

: (flat-length) ( seq -- n )
    [
        {
            { [ dup quotation? ] [ (flat-length) 1+ ] }
            { [ dup array? ] [ (flat-length) ] }
            { [ dup word? ] [ word-flat-length ] }
            { [ t ] [ drop 1 ] }
        } cond
    ] map sum ;

: flat-length ( seq -- n )
    [ word-def (flat-length) ] with-scope ;

: will-inline-method ( node word -- method-spec/t quot/t )
    #! t indicates failure
    tuck dispatching-class dup [
        swap [ 2array ] 2keep
        method method-word
        dup flat-length 10 >=
        [ 1quotation ] [ word-def ] if
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

: evaluate-predicate ( #call -- ? )
    dup node-param "predicating" word-prop >r
    node-class-first r> class< ;

: optimize-predicate ( #call -- node )
    dup evaluate-predicate swap
    dup node-successor #if? [
        dup drop-inputs >r
        node-successor swap 0 1 ? fold-branch
        r> [ set-node-successor ] keep
    ] [
        swap 1array inline-literals
    ] if ;

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
    dup node-param +inlined+ depends-on
    dup node-out-d length f <repetition> inline-literals ;

: partial-eval? ( #call -- ? )
    dup node-param "foldable" word-prop [
        dup node-in-d [ node-literal? ] with all?
    ] [
        drop f
    ] if ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [ node-literal ] with map ;

: partial-eval ( #call -- node )
    dup node-param +inlined+ depends-on
    dup literal-in-d over node-param 1quotation
    [ with-datastack inline-literals ] [ 2drop 2drop t ] recover ;

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
        >r node-input-classes r> specialized-length tail*
        [ types length 1 = ] all?
    ] [
        2drop f
    ] if ;

: optimistic-inline ( #call -- node )
    dup node-param dup +inlined+ depends-on
    word-def splice-quot ;

: method-body-inline? ( #call -- ? )
    node-param dup method-body?
    [ flat-length 8 <= ] [ drop f ] if ;

M: #call optimize-node*
    {
        { [ dup flush-eval? ] [ flush-eval ] }
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup find-identity ] [ apply-identities ] }
        { [ dup optimizer-hook ] [ optimize-hook ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ dup optimistic-inline? ] [ optimistic-inline ] }
        { [ dup method-body-inline? ] [ optimistic-inline ] }
        { [ t ] [ inline-method ] }
    } cond dup not ;
