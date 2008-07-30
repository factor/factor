! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math math.order namespaces sequences vectors words quotations
hashtables combinators effects classes classes.union
classes.algebra generic.math optimizer.math.partial
continuations optimizer.def-use optimizer.backend
generic.standard optimizer.specializers optimizer.def-use
optimizer.pattern-match generic.standard optimizer.control
kernel.private definitions sets summary ;
IN: optimizer.inlining

: remember-inlining ( node history -- )
    [ swap set-node-history ] curry each-node ;

: inlining-quot ( node quot -- node )
    over node-in-d dataflow-with
    dup rot infer-classes/node ;

: splice-quot ( #call quot history -- node )
    #! Must add history *before* splicing in, otherwise
    #! the rest of the IR will also remember the history
    pick node-history append
    >r dupd inlining-quot dup r> remember-inlining
    tuck splice-node ;

! A heuristic to avoid excessive inlining
SYMBOL: recursive-calls
DEFER: (flat-length)

: word-flat-length ( word -- n )
    {
        ! not inline
        { [ dup inline? not ] [ drop 1 ] }
        ! recursive and inline
        { [ dup recursive-calls get key? ] [ drop 10 ] }
        ! inline
        [ [ recursive-calls get conjoin ] [ def>> (flat-length) ] bi ]
    } cond ;

: (flat-length) ( seq -- n )
    [
        {
            { [ dup quotation? ] [ (flat-length) 2 + ] }
            { [ dup array? ] [ (flat-length) ] }
            { [ dup word? ] [ word-flat-length ] }
            [ drop 0 ]
        } cond
    ] sigma ;

: flat-length ( word -- n )
    H{ } clone recursive-calls [
        [ recursive-calls get conjoin ]
        [ def>> (flat-length) 5 /i ]
        bi
    ] with-variable ;

! Single dispatch method inlining optimization
! : dispatching-class ( node generic -- method/f )
!     tuck dispatch# over in-d>> <reversed> ?nth 2dup node-literal?
!     [ node-literal swap single-effective-method ]
!     [ node-class swap specific-method ]
!     if ;

: dispatching-class ( node generic -- method/f )
    tuck dispatch# over in-d>> <reversed> ?nth
    node-class swap specific-method ;

: inline-standard-method ( node generic -- node )
    dupd dispatching-class dup
    [ 1quotation f splice-quot ] [ 2drop t ] if ;

! Partial dispatch of math-generic words
: normalize-math-class ( class -- class' )
    {
        null
        fixnum bignum integer
        ratio rational
        float real
        complex number
        object
    } [ class<= ] with find nip ;

: inlining-math-method ( #call word -- quot/f )
    swap node-input-classes
    [ first normalize-math-class ]
    [ second normalize-math-class ] bi
    3dup math-both-known? [ math-method* ] [ 3drop f ] if ;

: inline-math-method ( #call word -- node/t )
    [ drop ] [ inlining-math-method ] 2bi
    dup [ f splice-quot ] [ 2drop t ] if ;

: inline-math-partial ( #call word -- node/t )
    [ drop ]
    [
        "derived-from" word-prop first
        inlining-math-method dup
    ]
    [ nip 1quotation ] 2tri
    [ = not ] [ drop ] 2bi and
    [ f splice-quot ] [ 2drop t ] if ;

: inline-method ( #call -- node )
    dup param>> {
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup math-generic? ] [ inline-math-method ] }
        { [ dup math-partial? ] [ inline-math-partial ] }
        [ 2drop t ]
    } cond ;

: literal-quot ( node literals -- quot )
    #! Outputs a quotation which drops the node's inputs, and
    #! pushes some literals.
    >r node-in-d length \ drop <repetition>
    r> [ literalize ] map append >quotation ;

: inline-literals ( node literals -- node )
    #! Make #shuffle -> #push -> #return -> successor
    dupd literal-quot f splice-quot ;

! Resolve type checks at compile time where possible
: comparable? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class<= >r classes-intersect? not r> or ;

: optimize-check? ( #call value class -- ? )
    >r node-class r> comparable? ;

: evaluate-check ( node value class -- ? )
    >r node-class r> class<= ;

: optimize-check ( #call value class -- node )
    #! If the predicate is followed by a branch we fold it
    #! immediately
    [ evaluate-check ] [ 2drop ] 3bi
    dup successor>> #if? [
        dup drop-inputs >r
        successor>> swap 0 1 ? fold-branch
        r> swap >>successor
    ] [
        swap 1array inline-literals
    ] if ;

: (optimize-predicate) ( #call -- #call value class )
    [ ] [ in-d>> first ] [ param>> "predicating" word-prop ] tri ;

: optimize-predicate? ( #call -- ? )
    dup param>> "predicating" word-prop [
        (optimize-predicate) optimize-check?
    ] [ drop f ] if ;

: optimize-predicate ( #call -- node )
    (optimize-predicate) optimize-check ;

: flush-eval? ( #call -- ? )
    dup node-param "flushable" word-prop
    [ node-out-d [ unused? ] all? ] [ drop f ] if ;

ERROR: flushed-eval-error word ;

M: flushed-eval-error summary
    drop "Flushed evaluation of word would have thrown an error" ;

: flushed-eval-quot ( #call -- quot )
    #! A quotation to replace flushed evaluations with. We can't
    #! just remove the code altogether, because if the optimizer
    #! knows the input types of a word, it assumes the inputs are
    #! of this type after the word returns, since presumably
    #! the word would have checked input types itself. However,
    #! if the word gets flushed, then it won't do this checking;
    #! so we have to do it here.
    [
        dup param>> "input-classes" word-prop [
            make-specializer %
            [ dup param>> literalize , \ flushed-eval-error , ] [ ] make ,
            \ unless ,
        ] when*
        dup in-d>> length [ \ drop , ] times
        out-d>> length [ f , ] times
    ] [ ] make ;

: flush-eval ( #call -- node )
    dup param>> +inlined+ depends-on
    dup flushed-eval-quot f splice-quot ;

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
    dup find-identity f splice-quot ;

: splice-word-def ( #call word def -- node )
    [ drop +inlined+ depends-on ] [ swap 1array ] 2bi
    splice-quot ;

: classes-known? ( #call -- ? )
    node-input-classes [
        [ class-types length 1 = ]
        [ union-class? not ]
        bi and
    ] contains? ;

: inlining-rank ( #call -- n )
    {
        [ param>> flat-length 24 swap [-] 4 /i ]
        [ param>> "default" word-prop -4 0 ? ]
        [ param>> "specializer" word-prop 1 0 ? ]
        [ param>> method-body? 1 0 ? ]
        [ classes-known? 2 0 ? ]
    } cleave + + + + ;

: should-inline? ( #call -- ? )
    inlining-rank 5 >= ;

: optimistic-inline? ( #call -- ? )
    dup param>> "specializer" word-prop
    [ should-inline? ] [ drop f ] if ;

: already-inlined? ( #call -- ? )
    [ param>> ] [ history>> ] bi memq? ;

: optimistic-inline ( #call -- node )
    dup already-inlined? [ drop t ] [
        dup param>> dup def>> splice-word-def
    ] if ;

: method-body-inline? ( #call -- ? )
    dup param>> method-body?
    [ should-inline? ] [ drop f ] if ;

M: #call optimize-node*
    {
        { [ dup flush-eval? ] [ flush-eval ] }
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup find-identity ] [ apply-identities ] }
        { [ dup optimizer-hook ] [ optimize-hook ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ dup optimistic-inline? ] [ optimistic-inline ] }
        { [ dup method-body-inline? ] [ optimistic-inline ] }
        [ inline-method ]
    } cond dup not ;
