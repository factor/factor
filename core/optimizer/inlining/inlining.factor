! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes generic.math continuations optimizer.def-use
optimizer.backend generic.standard optimizer.specializers
optimizer.def-use optimizer.pattern-match generic.standard
optimizer.control ;
IN: optimizer.inlining

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
    #! If the predicate is followed by a branch we fold it
    #! immediately
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
