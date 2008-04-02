IN: generic.standard.engines.tuple
USING: kernel classes.tuple.private hashtables assocs sorting
accessors combinators sequences slots.private math.parser words
effects namespaces generic generic.standard.engines
classes.algebra math math.private quotations ;

TUPLE: echelon-dispatch-engine n methods ;

C: <echelon-dispatch-engine> echelon-dispatch-engine

TUPLE: trivial-tuple-dispatch-engine methods ;

C: <trivial-tuple-dispatch-engine> trivial-tuple-dispatch-engine

TUPLE: tuple-dispatch-engine echelons ;

: push-echelon ( class method assoc -- )
    >r swap dup tuple-layout layout-echelon r>
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
    \ tuple-dispatch-engine construct-boa ;

: convert-tuple-methods ( assoc -- assoc' )
    tuple \ <tuple-dispatch-engine> convert-methods ;

M: trivial-tuple-dispatch-engine engine>quot
    methods>> engines>quots* linear-dispatch-quot ;

: hash-methods ( methods -- buckets )
    >alist V{ } clone [ class-hashes ] distribute-buckets
    [ <trivial-tuple-dispatch-engine> ] map ;

: class-hash-dispatch-quot ( methods -- quot )
    #! 1 slot == word hashcode
    [
        [ dup 1 slot ] %
        hash-methods [ engine>quot ] map hash-dispatch-quot %
    ] [ ] make ;

: tuple-dispatch-engine-word-name ( engine -- string )
    [
        generic get word-name %
        "/tuple-dispatch-engine/" %
        n>> #
    ] "" make ;

PREDICATE: tuple-dispatch-engine-word < word
    "tuple-dispatch-engine" word-prop ;

M: tuple-dispatch-engine-word stack-effect
    "tuple-dispatch-generic" word-prop stack-effect ;

: <tuple-dispatch-engine-word> ( engine -- word )
    tuple-dispatch-engine-word-name f <word>
    [ t "tuple-dispatch-engine" set-word-prop ]
    [ generic get "tuple-dispatch-generic" set-word-prop ]
    [ ]
    tri ;

: define-tuple-dispatch-engine-word ( engine quot -- word )
    >r <tuple-dispatch-engine-word> dup r> define ;

: tuple-dispatch-engine-body ( engine -- quot )
    #! 1 slot == tuple-layout
    #! 2 slot == 0 array-nth
    #! 4 slot == layout-superclasses
    [
        picker %
        [ 1 slot 4 slot ] %
        [ n>> 2 + , [ slot ] % ]
        [
            methods>> [
                <trivial-tuple-dispatch-engine> engine>quot
            ] [
                class-hash-dispatch-quot
            ] if-small? %
        ] bi
    ] [ ] make ;

M: echelon-dispatch-engine engine>quot
    dup tuple-dispatch-engine-body
    define-tuple-dispatch-engine-word
    1quotation ;

: >=-case-quot ( alist -- quot )
    default get [ drop ] prepend swap
    [ >r [ dupd fixnum>= ] curry r> \ drop prefix ] assoc-map
    alist>quot ;

M: tuple-dispatch-engine engine>quot
    #! 1 slot == tuple-layout
    #! 5 slot == layout-echelon
    [
        picker %
        [ 1 slot 5 slot ] %
        echelons>>
        [ [ engine>quot dup default set ] assoc-map ] with-scope
        >=-case-quot %
    ] [ ] make ;
