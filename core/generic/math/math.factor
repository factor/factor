! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.algebra combinators
definitions generic kernel kernel.private math math.order
math.private namespaces quotations sequences words ;
IN: generic.math

PREDICATE: math-class < class
    dup null bootstrap-word eq? [
        drop f
    ] [
        number bootstrap-word class<=
    ] if ;

<PRIVATE

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
    [ math-class-max ] 2keep [ (math-upgrade) ] bi-curry@ bi
    [ dup empty? [ [ dip ] curry ] unless ] dip [ ] append-as ;

ERROR: no-math-method left right generic ;

: default-math-method ( generic -- quot )
    [ no-math-method ] curry ;

<PRIVATE

: (math-method) ( generic class -- quot )
    over ?lookup-method ?or*
    [ 1quotation ]
    [ default-math-method ] if ;

PRIVATE>

: object-method ( generic -- quot )
    object bootstrap-word (math-method) ;

: math-method ( word class1 class2 -- quot )
    2dup and [
        [ 2array [ declare ] curry nip ]
        [ math-upgrade nip ]
        [ math-class-max over nearest-class (math-method) ]
        3tri 3append
    ] [
        2drop object-method
    ] if ;

<PRIVATE

SYMBOL: generic-word

: make-math-method-table ( classes quot: ( ... class -- ... quot ) -- alist )
    [ bootstrap-words ] dip [ keep swap ] curry map>alist ; inline

: math-alist>quot ( alist -- quot )
    [ generic-word get object-method ] dip alist>quot ;

: tag-dispatch-entry ( tag picker -- quot )
    [ "type" word-prop 1quotation [ tag ] [ eq? ] surround ] dip prepend ;

: tag-dispatch ( picker alist -- alist' )
    swap [ [ tag-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: tuple-dispatch-entry ( class picker -- quot )
    [ 1quotation [ { tuple } declare class-of ] [ eq? ] surround ] dip prepend ;

: tuple-dispatch ( picker alist -- alist' )
    swap [ [ tuple-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: math-dispatch-step ( picker quot: ( ... class -- ... quot ) -- quot )
    [ { bignum float fixnum } swap make-math-method-table ]
    [ { ratio complex } swap make-math-method-table tuple-dispatch ] 2bi
    tuple swap 2array prefix tag-dispatch ; inline

: fixnum-optimization ( word quot -- word quot' )
    [ dup fixnum bootstrap-word dup math-method ]
    [
        ! remove redundant fixnum check since we know
        ! both can't be fixnums in this branch
        dup length 3 - cut unclip
        [ length 2 - ] [ nth ] bi prefix append
    ] bi*
    [ if ] 2curry [ 2dup both-fixnums? ] prepend ;

PRIVATE>

SINGLETON: math-combination

M: math-combination make-default-method
    drop default-math-method ;

M: math-combination perform-combination
    drop dup generic-word [
        dup [ over ] [
            dup math-class? [
                [ dup ] [ math-method ] 2with math-dispatch-step
            ] [
                drop object-method
            ] if
        ] with math-dispatch-step
        fixnum-optimization
        define
    ] with-variable ;

PREDICATE: math-generic < generic
    "combination" word-prop math-combination? ;

M: math-generic definer drop \ MATH: f ;
