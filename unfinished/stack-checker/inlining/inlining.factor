! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry namespaces assocs kernel sequences words accessors
definitions math effects classes arrays combinators vectors
stack-checker.state
stack-checker.visitor
stack-checker.backend
stack-checker.branches
stack-checker.errors
stack-checker.known-words ;
IN: stack-checker.inlining

! Code to handle inline words. Much of the complexity stems from
! having to handle recursive inline words.

: (inline-word) ( word label -- )
    [ [ def>> ] keep ] dip infer-quot-recursive ;

TUPLE: inline-recursive word phi-in phi-out returns ;

: <inline-recursive> ( word -- label )
    inline-recursive new
        swap >>word
        V{ } clone >>returns ;

: quotation-param? ( obj -- ? )
    dup pair? [ second effect? ] [ drop f ] if ;

: make-copies ( values effect-in -- values' )
    [ quotation-param? [ copy-value ] [ drop <value> ] if ] 2map ;

SYMBOL: phi-in
SYMBOL: phi-out

: prepare-stack ( word -- )
    required-stack-effect in>> [ length ensure-d ] keep
    [ drop 1vector phi-in set ]
    [ make-copies phi-out set ]
    2bi ;

: emit-phi-function ( label -- )
    phi-in get >>phi-in
    phi-out get >>phi-out drop
    phi-in get phi-out get { { } } { } #phi,
    phi-out get >vector meta-d set ;

: entry-stack-height ( label -- stack )
    phi-out>> length ;

: check-return ( word label -- )
    2dup
    [ stack-effect effect-height ]
    [ entry-stack-height current-stack-height swap - ]
    bi*
    = [ 2drop ] [
        word>> current-stack-height
        unbalanced-recursion-error inference-error
    ] if ;

: end-recursive-word ( word label -- )
    [ check-return ]
    [ meta-d get [ #return, ] [ swap returns>> push ] 2bi ]
    bi ;

: recursive-word-inputs ( label -- n )
    entry-stack-height d-in get + ;

: (inline-recursive-word) ( word -- word label in out visitor )
    dup prepare-stack
    [
        init-inference
        nest-visitor

        dup <inline-recursive>
        [ dup emit-phi-function (inline-word) ]
        [ end-recursive-word ]
        [ ]
        2tri

        check->r

        dup recursive-word-inputs
        meta-d get
        stack-visitor get
    ] with-scope ;

: inline-recursive-word ( word -- )
    (inline-recursive-word)
    [ consume-d ] [ dup output-d ] [ ] tri* #recursive, ;

: check-call-height ( word label -- )
    entry-stack-height current-stack-height >
    [ diverging-recursion-error inference-error ] [ drop ] if ;

: call-site-stack ( label -- stack )
    required-stack-effect in>> length meta-d get swap tail* ;

: check-call-site-stack ( stack label -- )
    tuck phi-out>>
    [ dup known [ [ known ] bi@ = ] [ 2drop t ] if ] 2all?
    [ drop ] [ word>> inconsistent-recursive-call-error inference-error ] if ;

: add-call ( word label -- )
    [ check-call-height ]
    [
        [ call-site-stack ] dip
        [ check-call-site-stack ]
        [ phi-in>> swap [ suffix ] 2change-each ]
        2bi
    ] 2bi ;

: adjust-stack-effect ( effect -- effect' )
    [ in>> ] [ out>> ] bi
    meta-d get length pick length - object <repetition>
    '[ , prepend ] bi@
    <effect> ;

: insert-copy ( effect -- )
    in>> [ consume-d dup ] keep make-copies
    [ nip output-d ] [ #copy, ] 2bi ;

: call-recursive-inline-word ( word -- )
    dup "recursive" word-prop [
        [ required-stack-effect adjust-stack-effect ] [ ] [ recursive-label ] tri
        [ 2drop insert-copy ]
        [ add-call drop ]
        [ nip '[ , #call-recursive, ] consume/produce ]
        3tri
    ] [ undeclared-recursion-error inference-error ] if ;

: inline-word ( word -- )
    [ +inlined+ depends-on ]
    [
        {
            { [ dup inline-recursive-label ] [ call-recursive-inline-word ] }
            { [ dup "recursive" word-prop ] [ inline-recursive-word ] }
            [ dup (inline-word) ]
        } cond
    ] bi ;

M: word apply-object
    dup inline? [ inline-word ] [ non-inline-word ] if ;
