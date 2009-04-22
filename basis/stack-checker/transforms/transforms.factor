! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors arrays kernel kernel.private combinators.private
words sequences generic math math.order namespaces make quotations
assocs combinators combinators.short-circuit classes.tuple
classes.tuple.private effects summary hashtables classes generic sets
definitions generic.standard slots.private continuations locals
sequences.private generalizations stack-checker.backend
stack-checker.state stack-checker.visitor stack-checker.errors
stack-checker.values stack-checker.recursive-state ;
IN: stack-checker.transforms

: call-transformer ( word stack quot -- newquot )
    '[ _ _ with-datastack [ length 1 assert= ] [ first ] bi nip ]
    [ transform-expansion-error ]
    recover ;

:: ((apply-transform)) ( word quot values stack rstate -- )
    rstate recursive-state
    [ word stack quot call-transformer ] with-variable
    [
        word inlined-dependency depends-on
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
        dup peek callable? [
            dup peek swap but-last
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
M\ tuple-class boa t "no-compile" set-word-prop

\ new [
    dup tuple-class? [
        dup inlined-dependency depends-on
        [
            [ all-slots [ initial>> literalize , ] each ]
            [ literalize , ] bi
            \ boa ,
        ] [ ] make
    ] [ drop f ] if
] 1 define-transform

! Fast at for integer maps
CONSTANT: lookup-table-at-max 256

: lookup-table-at? ( assoc -- ? )
    #! Can we use a fast byte array test here?
    {
        [ assoc-size 4 > ]
        [ values [ ] all? ]
        [ keys [ integer? ] all? ]
        [ keys [ 0 lookup-table-at-max between? ] all? ]
    } 1&& ;

: lookup-table-seq ( assoc -- table )
    [ keys supremum 1+ ] keep '[ _ at ] { } map-as ;

: lookup-table-quot ( seq -- newquot )
    lookup-table-seq
    '[
        _ over integer? [
            2dup bounds-check? [
                nth-unsafe dup >boolean
            ] [ 2drop f f ] if
        ] [ 2drop f f ] if
    ] ;

: fast-lookup-table-at? ( assoc -- ? )
    values {
        [ [ integer? ] all? ]
        [ [ 0 254 between? ] all? ]
    } 1&& ;

: fast-lookup-table-seq ( assoc -- table )
    lookup-table-seq [ 255 or ] B{ } map-as ;

: fast-lookup-table-quot ( seq -- newquot )
    fast-lookup-table-seq
    '[
        _ over integer? [
            2dup bounds-check? [
                nth-unsafe dup 255 eq? [ drop f f ] [ t ] if
            ] [ 2drop f f ] if
        ] [ 2drop f f ] if
    ] ;

: at-quot ( assoc -- quot )
    dup lookup-table-at? [
        dup fast-lookup-table-at? [
            fast-lookup-table-quot
        ] [
            lookup-table-quot
        ] if
    ] [ drop f ] if ;

\ at* [ at-quot ] 1 define-transform

! Membership testing
: member-quot ( seq -- newquot )
    dup length 4 <= [
        [ drop f ] swap
        [ literalize [ t ] ] { } map>assoc linear-case-quot
    ] [
        unique [ key? ] curry
    ] if ;

\ member? [
    dup sequence? [ member-quot ] [ drop f ] if
] 1 define-transform

: memq-quot ( seq -- newquot )
    [ [ dupd eq? ] curry [ drop t ] ] { } map>assoc
    [ drop f ] suffix [ cond ] curry ;

\ memq? [
    dup sequence? [ memq-quot ] [ drop f ] if
] 1 define-transform

! Index search
\ index [
    dup sequence? [
        dup length 4 >= [
            dup length zip >hashtable '[ _ at ]
        ] [ drop f ] if
    ] [ drop f ] if
] 1 define-transform

! Shuffling
: nths-quot ( indices -- quot )
    [ [ '[ _ swap nth ] ] map ] [ length ] bi
    '[ _ cleave _ narray ] ;

\ shuffle [
    shuffle-mapping nths-quot
] 1 define-transform
