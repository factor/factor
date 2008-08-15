! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry namespaces assocs kernel sequences words accessors
definitions math math.order effects classes arrays combinators
vectors arrays
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

TUPLE: inline-recursive < identity-tuple
id
word
enter-out enter-recursive
return calls
fixed-point
introductions
loop? ;

M: inline-recursive hashcode* id>> hashcode* ;

: inlined-block? ( word -- ? ) "inlined-block" word-prop ;

: <inline-recursive> ( word -- label )
    inline-recursive new
        gensym dup t "inlined-block" set-word-prop >>id
        swap >>word ;

: quotation-param? ( obj -- ? )
    dup pair? [ second effect? ] [ drop f ] if ;

: make-copies ( values effect-in -- values' )
    [ quotation-param? [ copy-value ] [ drop <value> ] if ] 2map ;

SYMBOL: enter-in
SYMBOL: enter-out

: prepare-stack ( word -- )
    required-stack-effect in>> [ length ensure-d ] keep
    [ drop enter-in set ] [ make-copies enter-out set ] 2bi ;

: emit-enter-recursive ( label -- )
    enter-out get >>enter-out
    enter-in get enter-out get #enter-recursive,
    enter-out get >vector meta-d set ;

: entry-stack-height ( label -- stack )
    enter-out>> length ;

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
    [ meta-d get dup copy-values dup meta-d set #return-recursive, ]
    bi ;

: recursive-word-inputs ( label -- n )
    entry-stack-height d-in get + ;

: (inline-recursive-word) ( word -- word label in out visitor )
    dup prepare-stack
    [
        init-inference
        nest-visitor

        dup <inline-recursive>
        [ dup emit-enter-recursive (inline-word) ]
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
    [ consume-d ] [ output-d ] [ ] tri* #recursive, ;

: check-call-height ( word label -- )
    entry-stack-height current-stack-height >
    [ diverging-recursion-error inference-error ] [ drop ] if ;

: call-site-stack ( label -- stack )
    required-stack-effect in>> length meta-d get swap tail* ;

: check-call-site-stack ( stack label -- )
    tuck enter-out>>
    [ dup known [ [ known ] bi@ = ] [ 2drop t ] if ] 2all?
    [ drop ] [ word>> inconsistent-recursive-call-error inference-error ] if ;

: add-call ( word label -- )
    [ check-call-height ]
    [ [ call-site-stack ] dip check-call-site-stack ] 2bi ;

: adjust-stack-effect ( effect -- effect' )
    [ in>> ] [ out>> ] bi
    meta-d get length pick length - 0 max
    object <repetition> '[ , prepend ] bi@
    <effect> ;

: call-recursive-inline-word ( word -- )
    dup "recursive" word-prop [
        [ required-stack-effect adjust-stack-effect ] [ ] [ recursive-label ] tri
        [ add-call drop ]
        [ nip '[ , #call-recursive, ] consume/produce ]
        3bi
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
