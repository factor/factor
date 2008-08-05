! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors arrays kernel words sequences generic math
namespaces quotations assocs combinators classes.tuple
classes.tuple.private effects summary hashtables classes generic
sets definitions generic.standard slots.private continuations
stack-checker.backend stack-checker.state stack-checker.visitor
stack-checker.errors ;
IN: stack-checker.transforms

SYMBOL: +transform-quot+
SYMBOL: +transform-n+

: (apply-transform) ( quot n -- newquot )
    dup zero? [
        drop recursive-state get 1array
    ] [
        consume-d
        [ #drop, ]
        [ [ literal value>> ] map ]
        [ first literal recursion>> ] tri prefix
    ] if
    swap with-datastack ;

: apply-transform ( word -- )
    [ +inlined+ depends-on ] [
        [ +transform-quot+ word-prop ]
        [ +transform-n+ word-prop ]
        bi (apply-transform)
        first2 swap infer-quot
    ] bi ;

: apply-macro ( word -- )
    [ +inlined+ depends-on ] [
        [ "macro" word-prop ]
        [ "declared-effect" word-prop in>> length ]
        bi (apply-transform)
        first2 swap infer-quot
    ] bi ;

: define-transform ( word quot n -- )
    [ drop +transform-quot+ set-word-prop ]
    [ nip +transform-n+ set-word-prop ]
    3bi ;

! Combinators
\ cond [ cond>quot ] 1 define-transform

\ case [
    dup empty? [
        drop [ no-case ]
    ] [
        dup peek quotation? [
            dup peek swap but-last
        ] [
            [ no-case ] swap
        ] if case>quot
    ] if
] 1 define-transform

\ cleave [ cleave>quot ] 1 define-transform

\ 2cleave [ 2cleave>quot ] 1 define-transform

\ 3cleave [ 3cleave>quot ] 1 define-transform

\ spread [ spread>quot ] 1 define-transform

\ boa [
    dup tuple-class? [
        dup +inlined+ depends-on
        [ "boa-check" word-prop ]
        [ tuple-layout '[ , <tuple-boa> ] ]
        bi append
    ] [
        \ boa \ no-method boa time-bomb
    ] if
] 1 define-transform

\ (call-next-method) [
    [ [ +inlined+ depends-on ] bi@ ] [ next-method-quot ] 2bi
] 2 define-transform

! Deprecated
\ get-slots [ [ 1quotation ] map [ cleave ] curry ] 1 define-transform

\ set-slots [ <reversed> [ get-slots ] curry ] 1 define-transform
