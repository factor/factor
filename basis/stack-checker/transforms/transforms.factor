! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors arrays kernel kernel.private combinators.private
words sequences generic math math.order namespaces quotations
assocs combinators combinators.short-circuit classes.tuple
classes.tuple.private effects summary hashtables classes sets
definitions generic.standard slots.private continuations locals
sequences.private generalizations stack-checker.backend
stack-checker.state stack-checker.visitor stack-checker.errors
stack-checker.values stack-checker.recursive-state
stack-checker.dependencies ;
IN: stack-checker.transforms

: call-transformer ( word stack quot -- newquot )
    '[ _ _ with-datastack [ length 1 assert= ] [ first ] bi nip ]
    [ transform-expansion-error ]
    recover ;

:: ((apply-transform)) ( word quot values stack rstate -- )
    rstate recursive-state
    [ word stack quot call-transformer ] with-variable
    [
        values [ length meta-d shorten-by ] [ #drop, ] bi
        rstate infer-quot
    ] [ word infer-word ] if* ;

: literals? ( values -- ? ) [ literal-value? ] all? ;

: (apply-transform) ( word quot n -- )
    ensure-d dup literals? [
        dup empty? [ dup recursive-state get ] [
            [ ]
            [ [ literal value>> ] map ]
            [ first literal recursion>> ] tri
        ] if
        ((apply-transform))
    ] [ 2drop infer-word ] if ;

: apply-transform ( word -- )
    [ ] [ "transform-quot" word-prop ] [ "transform-n" word-prop ] tri
    (apply-transform) ;

: apply-macro ( word -- )
    [ ] [ "macro" word-prop ] [ "declared-effect" word-prop in>> length ] tri
    (apply-transform) ;

: define-transform ( word quot n -- )
    [ drop "transform-quot" set-word-prop ]
    [ nip "transform-n" set-word-prop ]
    3bi ;

! Combinators
\ cond [ cond>quot ] 1 define-transform

\ cond t "no-compile" set-word-prop

\ case [
    [
        [ no-case ]
    ] [
        dup last callable? [
            dup last swap but-last
        ] [
            [ no-case ] swap
        ] if case>quot
    ] if-empty
] 1 define-transform

\ case t "no-compile" set-word-prop

\ cleave [ cleave>quot ] 1 define-transform

\ cleave t "no-compile" set-word-prop

\ 2cleave [ 2cleave>quot ] 1 define-transform

\ 2cleave t "no-compile" set-word-prop

\ 3cleave [ 3cleave>quot ] 1 define-transform

\ 3cleave t "no-compile" set-word-prop

\ spread [ spread>quot ] 1 define-transform

\ spread t "no-compile" set-word-prop

\ 0&& [ '[ _ 0 n&& ] ] 1 define-transform

\ 0&& t "no-compile" set-word-prop

\ 1&& [ '[ _ 1 n&& ] ] 1 define-transform

\ 1&& t "no-compile" set-word-prop

\ 2&& [ '[ _ 2 n&& ] ] 1 define-transform

\ 2&& t "no-compile" set-word-prop

\ 3&& [ '[ _ 3 n&& ] ] 1 define-transform

\ 3&& t "no-compile" set-word-prop

\ 0|| [ '[ _ 0 n|| ] ] 1 define-transform

\ 0|| t "no-compile" set-word-prop

\ 1|| [ '[ _ 1 n|| ] ] 1 define-transform

\ 1|| t "no-compile" set-word-prop

\ 2|| [ '[ _ 2 n|| ] ] 1 define-transform

\ 2|| t "no-compile" set-word-prop

\ 3|| [ '[ _ 3 n|| ] ] 1 define-transform

\ 3|| t "no-compile" set-word-prop

\ (call-next-method) [
    [
        [ "method-class" word-prop ]
        [ "method-generic" word-prop ] bi
        [ inlined-dependency depends-on ] bi@
    ] [
        [ next-method-quot ]
        [ '[ _ no-next-method ] ] bi or
    ] bi
] 1 define-transform

\ (call-next-method) t "no-compile" set-word-prop

! Constructors
\ boa [
    dup tuple-class? [
        dup inlined-dependency depends-on
        [ "boa-check" word-prop [ ] or ]
        [ tuple-layout '[ _ <tuple-boa> ] ]
        bi append
    ] [ drop f ] if
] 1 define-transform

\ boa t "no-compile" set-word-prop
