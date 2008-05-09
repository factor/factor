! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes.tuple.private hashtables assocs sorting
accessors combinators sequences slots.private math.parser words
effects namespaces generic generic.standard.engines
classes.algebra math math.private kernel.private
quotations arrays ;
IN: generic.standard.engines.tuple

TUPLE: echelon-dispatch-engine n methods ;

C: <echelon-dispatch-engine> echelon-dispatch-engine

TUPLE: trivial-tuple-dispatch-engine methods ;

C: <trivial-tuple-dispatch-engine> trivial-tuple-dispatch-engine

TUPLE: tuple-dispatch-engine echelons ;

: push-echelon ( class method assoc -- )
    >r swap dup "layout" word-prop layout-echelon r>
    [ ?set-at ] change-at ;

: echelon-sort ( assoc -- assoc' )
    V{ } clone [
        [
            push-echelon
        ] curry assoc-each
    ] keep sort-keys ;

: <tuple-dispatch-engine> ( methods -- engine )
    echelon-sort
    [ dupd <echelon-dispatch-engine> ] assoc-map
    \ tuple-dispatch-engine boa ;

: convert-tuple-methods ( assoc -- assoc' )
    tuple bootstrap-word
    \ <tuple-dispatch-engine> convert-methods ;

M: trivial-tuple-dispatch-engine engine>quot
    methods>> engines>quots* linear-dispatch-quot ;

: hash-methods ( methods -- buckets )
    >alist V{ } clone [ hashcode 1array ] distribute-buckets
    [ <trivial-tuple-dispatch-engine> ] map ;

: word-hashcode% [ 1 slot ] % ;

: class-hash-dispatch-quot ( methods -- quot )
    [
        \ dup ,
        word-hashcode%
        hash-methods [ engine>quot ] map hash-dispatch-quot %
    ] [ ] make ;

: engine-word-name ( -- string )
    generic get word-name "/tuple-dispatch-engine" append ;

PREDICATE: engine-word < word
    "tuple-dispatch-generic" word-prop generic? ;

M: engine-word stack-effect
    "tuple-dispatch-generic" word-prop
    [ extra-values ] [ stack-effect ] bi
    dup [ clone [ length + ] change-in ] [ 2drop f ] if ;

M: engine-word compiled-crossref?
    drop t ;

: remember-engine ( word -- )
    generic get "engines" word-prop push ;

: <engine-word> ( -- word )
    engine-word-name f <word>
    dup generic get "tuple-dispatch-generic" set-word-prop ;

: define-engine-word ( quot -- word )
    >r <engine-word> dup r> define ;

: array-nth% 2 + , [ slot { word } declare ] % ;

: tuple-layout-superclasses ( obj -- array )
    { tuple } declare
    1 slot { tuple-layout } declare
    4 slot { array } declare ; inline

: tuple-dispatch-engine-body ( engine -- quot )
    [
        picker %
        [ tuple-layout-superclasses ] %
        [ n>> array-nth% ]
        [
            methods>> [
                <trivial-tuple-dispatch-engine> engine>quot
            ] [
                class-hash-dispatch-quot
            ] if-small? %
        ] bi
    ] [ ] make ;

M: echelon-dispatch-engine engine>quot
    dup n>> zero? [
        methods>> dup assoc-empty?
        [ drop default get ] [ values first engine>quot ] if
    ] [
        [
            picker %
            [ tuple-layout-superclasses ] %
            [ n>> array-nth% ]
            [
                methods>> [
                    <trivial-tuple-dispatch-engine> engine>quot
                ] [
                    class-hash-dispatch-quot
                ] if-small? %
            ] bi
        ] [ ] make
    ] if ;

: >=-case-quot ( alist -- quot )
    default get [ drop ] prepend swap
    [ >r [ dupd fixnum>= ] curry r> \ drop prefix ] assoc-map
    alist>quot ;

: tuple-layout-echelon ( obj -- array )
    { tuple } declare
    1 slot { tuple-layout } declare
    5 slot ; inline

M: tuple-dispatch-engine engine>quot
    [
        picker %
        [ tuple-layout-echelon ] %
        [
            tuple assumed set
            echelons>> dup empty? [
                unclip-last
                [
                    [
                        engine>quot define-engine-word
                        [ remember-engine ] [ 1quotation ] bi
                        dup default set
                    ] assoc-map
                ]
                [ first2 engine>quot 2array ] bi*
                suffix
            ] unless
        ] with-scope
        >=-case-quot %
    ] [ ] make ;
