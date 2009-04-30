! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private math
namespaces sequences words quotations layouts combinators
sequences.private classes classes.builtin classes.algebra
definitions math.order math.private assocs ;
IN: generic.math

PREDICATE: math-class < class
    dup null bootstrap-word eq? [
        drop f
    ] [
        number bootstrap-word class<=
    ] if ;

<PRIVATE

: last/first ( seq -- pair ) [ peek ] [ first ] bi 2array ;

: bootstrap-words ( classes -- classes' )
    [ bootstrap-word ] map ;

: math-precedence ( class -- pair )
    [
        { fixnum integer rational real number object } bootstrap-words
        swap [ swap class<= ] curry find drop -1 or
    ] [
        { fixnum bignum ratio float complex object } bootstrap-words
        swap [ class<= ] curry find drop -1 or
    ] bi 2array ;

: (math-upgrade) ( max class -- quot )
    dupd = [ drop [ ] ] [ "coercer" word-prop [ ] or ] if ;

PRIVATE>

: math-class-max ( class1 class2 -- class )
    [ [ math-precedence ] bi@ after? ] most ;

: math-upgrade ( class1 class2 -- quot )
    [ math-class-max ] 2keep
    [
        (math-upgrade)
        dup empty? [ [ dip ] curry [ ] like ] unless
    ] [ (math-upgrade) ]
    bi-curry* bi append ;

ERROR: no-math-method left right generic ;

: default-math-method ( generic -- quot )
    [ no-math-method ] curry [ ] like ;

<PRIVATE

: applicable-method ( generic class -- quot )
    over method
    [ 1quotation ]
    [ default-math-method ] ?if ;

PRIVATE>

: object-method ( generic -- quot )
    object bootstrap-word applicable-method ;

: math-method ( word class1 class2 -- quot )
    2dup and [
        [ 2array [ declare ] curry nip ]
        [ math-upgrade nip ]
        [ math-class-max over order min-class applicable-method ]
        3tri 3append
    ] [
        2drop object-method
    ] if ;

<PRIVATE

SYMBOL: generic-word

: make-math-method-table ( classes quot: ( class -- quot ) -- alist )
    [ bootstrap-words ] dip
    [ [ drop ] [ call ] 2bi ] curry { } map>assoc ; inline

: math-alist>quot ( alist -- quot )
    [ generic-word get object-method ] dip alist>quot ;

: tag-dispatch-entry ( tag picker -- quot )
    [ "type" word-prop 1quotation [ tag ] [ eq? ] surround ] dip prepend ;

: tag-dispatch ( picker alist -- alist' )
    swap [ [ tag-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: tuple-dispatch-entry ( class picker -- quot )
    [ 1quotation [ { tuple } declare class ] [ eq? ] surround ] dip prepend ;

: tuple-dispatch ( picker alist -- alist' )
    swap [ [ tuple-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: math-dispatch-step ( picker quot: ( class -- quot ) -- quot )
    [ [ { bignum float fixnum } ] dip make-math-method-table ]
    [ [ { ratio complex } ] dip make-math-method-table tuple-dispatch ] 2bi
    tuple swap 2array prefix tag-dispatch ; inline

PRIVATE>

SINGLETON: math-combination

M: math-combination make-default-method
    drop default-math-method ;

M: math-combination perform-combination
    drop dup generic-word [
        dup
        [ fixnum bootstrap-word dup math-method ]
        [
            [ over ] [
                dup math-class? [
                    [ dup ] [ math-method ] with with math-dispatch-step
                ] [
                    drop object-method
                ] if
            ] with math-dispatch-step
        ] bi
        [ if ] 2curry [ 2dup both-fixnums? ] prepend
        define
    ] with-variable ;

PREDICATE: math-generic < generic ( word -- ? )
    "combination" word-prop math-combination? ;

M: math-generic definer drop \ MATH: f ;
