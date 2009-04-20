! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes.tuple.private hashtables assocs sorting
accessors combinators sequences slots.private math.parser words
effects namespaces make generic generic.standard.engines
classes.algebra math math.private kernel.private
quotations arrays definitions ;
IN: generic.standard.engines.tuple

: nth-superclass% ( n -- ) 2 * 5 + , \ slot , ; inline

: nth-hashcode% ( n -- ) 2 * 6 + , \ slot , ; inline

: tuple-layout% ( -- )
    [ { tuple } declare 1 slot { array } declare ] % ; inline

: tuple-layout-echelon% ( -- )
    [ 4 slot ] % ; inline

TUPLE: echelon-dispatch-engine n methods ;

C: <echelon-dispatch-engine> echelon-dispatch-engine

TUPLE: trivial-tuple-dispatch-engine n methods ;

C: <trivial-tuple-dispatch-engine> trivial-tuple-dispatch-engine

TUPLE: tuple-dispatch-engine echelons ;

: push-echelon ( class method assoc -- )
    [ swap dup "layout" word-prop third ] dip
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
    [ n>> ] [ methods>> ] bi dup assoc-empty? [
        2drop default get [ drop ] prepend
    ] [
        [
            [ nth-superclass% ]
            [ engines>quots* linear-dispatch-quot % ] bi*
        ] [ ] make
    ] if ;

: hash-methods ( n methods -- buckets )
    >alist V{ } clone [ hashcode 1array ] distribute-buckets
    [ <trivial-tuple-dispatch-engine> ] with map ;

: class-hash-dispatch-quot ( n methods -- quot )
    [
        \ dup ,
        [ drop nth-hashcode% ]
        [ hash-methods [ engine>quot ] map hash-dispatch-quot % ] 2bi
    ] [ ] make ;

: engine-word-name ( -- string )
    generic get name>> "/tuple-dispatch-engine" append ;

PREDICATE: engine-word < word
    "tuple-dispatch-generic" word-prop generic? ;

M: engine-word stack-effect
    "tuple-dispatch-generic" word-prop
    [ extra-values ] [ stack-effect ] bi
    dup [
        [ in>> length + ] [ out>> ] [ terminated?>> ] tri
        effect boa
    ] [ 2drop f ] if ;

M: engine-word where "tuple-dispatch-generic" word-prop where ;

M: engine-word crossref? "forgotten" word-prop not ;

M: engine-word irrelevant? drop t ;

: remember-engine ( word -- )
    generic get "engines" word-prop push ;

: <engine-word> ( -- word )
    engine-word-name f <word>
    dup generic get "tuple-dispatch-generic" set-word-prop ;

: define-engine-word ( quot -- word )
    [ <engine-word> dup ] dip define ;

: tuple-dispatch-engine-body ( engine -- quot )
    [
        picker %
        tuple-layout%
        [ n>> ] [ methods>> ] bi
        [ <trivial-tuple-dispatch-engine> engine>quot ]
        [ class-hash-dispatch-quot ]
        if-small? %
    ] [ ] make ;

M: echelon-dispatch-engine engine>quot
    dup n>> zero? [
        methods>> dup assoc-empty?
        [ drop default get ] [ values first engine>quot ] if
    ] [
        tuple-dispatch-engine-body
    ] if ;

: >=-case-quot ( default alist -- quot )
    [ [ drop ] prepend ] dip
    [
        [ [ dup ] swap [ fixnum>= ] curry compose ]
        [ [ drop ] prepose ]
        bi* [ ] like
    ] assoc-map
    alist>quot ;

: simplify-echelon-alist ( default alist -- default' alist' )
    dup empty? [
        dup first first 1 <= [
            nip unclip second swap
            simplify-echelon-alist
        ] when
    ] unless ;

: echelon-case-quot ( alist -- quot )
    #! We don't have to test for echelon 1 since all tuple
    #! classes are at least at depth 1 in the inheritance
    #! hierarchy.
    default get swap simplify-echelon-alist
    [
        [
            picker %
            tuple-layout%
            tuple-layout-echelon%
            >=-case-quot %
        ] [ ] make
    ] unless-empty ;

M: tuple-dispatch-engine engine>quot
    [
        [
            tuple assumed set
            echelons>> unclip-last
            [
                [
                    engine>quot
                    over 0 = [
                        define-engine-word
                        [ remember-engine ] [ 1quotation ] bi
                    ] unless
                    dup default set
                ] assoc-map
            ]
            [ first2 engine>quot 2array ] bi*
            suffix
        ] with-scope
        echelon-case-quot %
    ] [ ] make ;
