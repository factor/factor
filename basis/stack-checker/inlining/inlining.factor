! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays effects fry hints kernel locals math
math.order namespaces sequences stack-checker.backend
stack-checker.dependencies stack-checker.errors
stack-checker.known-words stack-checker.recursive-state
stack-checker.state stack-checker.values stack-checker.visitor
vectors words ;
IN: stack-checker.inlining

! Code to handle inline words. Much of the complexity stems from
! having to handle recursive inline words.

: infer-inline-word-def ( word label -- )
    [ drop specialized-def ] [ add-inline-word ] 2bi infer-quot ;

TUPLE: inline-recursive < identity-tuple
id
word
enter-out enter-recursive
return calls
fixed-point
introductions
loop? ;

: inlined-block? ( word -- ? ) "inlined-block" word-prop ;

: <inline-recursive> ( word -- label )
    inline-recursive new
        gensym dup t "inlined-block" set-word-prop >>id
        swap >>word ;

: quotation-param? ( obj -- ? )
    dup pair? [ second effect? ] [ drop f ] if ;

: make-copies ( values effect-in -- values' )
    [ length cut* ] keep
    [ quotation-param? [ copy-value ] [ drop <value> ] if ] 2map
    [ length make-values ] dip append ;

SYMBOL: enter-in
SYMBOL: enter-out

: prepare-stack ( word -- )
    required-stack-effect in>>
    [ length ensure-d drop ] [
        meta-d clone enter-in set
        meta-d swap make-copies enter-out set
    ] bi ;

: emit-enter-recursive ( label -- )
    enter-out get >>enter-out
    enter-in get enter-out get #enter-recursive,
    enter-out get >vector (meta-d) set ;

: entry-stack-height ( label -- stack )
    enter-out>> length ;

:: check-return ( word label -- )
    word stack-height
    current-stack-height label entry-stack-height -
    = [
        terminated? get [
            label word>> current-stack-height
            unbalanced-recursion-error inference-error
        ] unless
    ] unless ;

: end-recursive-word ( word label -- )
    [ check-return ]
    [ meta-d dup copy-values dup (meta-d) set #return-recursive, ]
    bi ;

: recursive-word-inputs ( label -- n )
    entry-stack-height input-count get + ;

: (inline-recursive-word) ( word -- label in out visitor terminated? )
    dup prepare-stack
    [
        init-inference
        nest-visitor

        dup <inline-recursive>
        [ dup emit-enter-recursive infer-inline-word-def ]
        [ end-recursive-word ]
        [ nip ]
        2tri

        dup recursive-word-inputs
        meta-d
        stack-visitor get
        terminated? get
    ] with-scope ;

: inline-recursive-word ( word -- )
    (inline-recursive-word)
    [ [ consume-d ] [ output-d ] [ ] tri* #recursive, ] dip
    [ terminate ] when ;

: check-call-height ( label -- )
    dup entry-stack-height current-stack-height > [
        word>> diverging-recursion-error inference-error
    ] [ drop ] if ;

: trim-stack ( label seq -- stack )
    swap word>> required-stack-effect in>> length tail* ;

: call-site-stack ( label -- stack )
    meta-d trim-stack ;

: trimmed-enter-out ( label -- stack )
    dup enter-out>> trim-stack ;

GENERIC: (undeclared-known) ( value -- known )
M: object (undeclared-known) ;
M: declared-effect (undeclared-known) known>> (undeclared-known) ;

: undeclared-known ( value -- known ) known (undeclared-known) ;

: check-call-site-stack ( label -- )
    [ ] [ call-site-stack ] [ trimmed-enter-out ] tri
    [ dup undeclared-known [ [ undeclared-known ] same? ] [ 2drop t ] if ] 2all?
    [ drop ] [ word>> inconsistent-recursive-call-error inference-error ] if ;

: check-call ( label -- )
    [ check-call-height ] [ check-call-site-stack ] bi ;

: adjust-stack-effect ( effect -- effect' )
    [ in>> ] [ out>> ] bi meta-d length pick length [-]
    object <repetition> '[ _ prepend ] bi@
    <effect> ;

: call-recursive-inline-word ( word label -- )
    over recursive? [
        [ required-stack-effect adjust-stack-effect ] dip
        [ check-call ] [ '[ _ #call-recursive, ] consume/produce ] bi
    ] [
        drop undeclared-recursion-error inference-error
    ] if ;

: inline-word ( word -- )
    commit-literals
    [ +definition+ depends-on ]
    [ declare-input-effects ]
    [
        dup inline-recursive-label [
            call-recursive-inline-word
        ] [
            dup recursive?
            [ inline-recursive-word ]
            [ dup infer-inline-word-def ]
            if
        ] if*
    ] tri ;

M: word apply-object
    dup inline? [ inline-word ] [ non-inline-word ] if ;
