! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: words parser kernel namespaces lists strings math
hashtables errors vectors ;

: make-tuple ( class size -- tuple )
    #! Internal allocation function. Do not call it directly,
    #! since you can fool the runtime and corrupt memory by
    #! specifying an incorrect size.
    <tuple> [ 0 swap set-array-nth ] keep ;

IN: generic

BUILTIN: tuple 18 [ 1 array-capacity f ] ;

#! arrayed objects can be passed to array-capacity,
#! array-nth, and set-array-nth.
UNION: arrayed array tuple ;

: class ( obj -- class )
    #! The class of an object.
    dup tuple? [ 2 slot ] [ type builtin-type ] ifte ;

: (literal-tuple) ( list size -- tuple )
    dup <tuple> swap [
        ( list tuple n -- list tuple n )
        pick car pick pick swap set-array-nth
        >r >r cdr r> r>
    ] repeat nip ;

: literal-tuple ( list -- tuple )
    dup car "tuple-size" word-prop over length over = [
        (literal-tuple)
    ] [
        "Incorrect tuple length" throw
    ] ifte ;

: tuple-predicate ( word -- )
    #! Make a foo? word for testing the tuple class at the top
    #! of the stack.
    dup predicate-word swap [ swap class eq? ] cons
    define-compound ;

: check-shape ( word slots -- )
    #! If the new list of slots is different from the previous,
    #! forget the old definition.
    >r "use" get search dup [
        dup "tuple-size" word-prop r> length 1 + =
        [ drop ] [ forget ] ifte
    ] [
        r> 2drop
    ] ifte ;

: tuple-slots ( tuple slots -- )
    2dup length 1 + "tuple-size" set-word-prop
    3 -rot simple-slots ;

: constructor-word ( word -- word )
    word-name "<" swap ">" cat3 create-in ;

: define-constructor ( word def -- )
    >r [ constructor-word ] keep [
        dup literal, "tuple-size" word-prop , \ make-tuple ,
    ] make-list r> append define-compound ;

: default-constructor ( tuple -- )
    dup [
        "slots" word-prop
        reverse [ last unit , \ keep , ] each
    ] make-list define-constructor ;

: define-tuple ( tuple slots -- )
    2dup check-shape
    >r create-in
    dup save-location
    dup intern-symbol
    dup tuple-predicate
    dup tuple "metaclass" set-word-prop
    dup r> tuple-slots
    default-constructor ;

: tuple-delegate ( tuple -- obj )
    dup tuple? [
        dup class "delegate-slot" word-prop dup [
            >fixnum slot
        ] [
            2drop f
        ] ifte
    ] [
        drop f
    ] ifte ;

: alist>quot ( default alist -- quot )
    #! Turn an association list that maps values to quotations
    #! into a quotation that executes a quotation depending on
    #! the value on the stack.
    [
        [
            unswons
            \ dup , unswons literal, \ = , \ drop swons ,
            alist>quot , \ ifte ,
        ] make-list
    ] when* ;

: (hash>quot) ( default hash -- quot )
    [
        \ dup , \ hashcode , dup bucket-count , \ rem ,
        buckets>list [ alist>quot ] map-with list>vector ,
        \ dispatch ,
    ] make-list ;

: hash>quot ( default hash -- quot )
    #! Turn a hash  table that maps values to quotations into a
    #! quotation that executes a quotation depending on the
    #! value on the stack.
    dup hash-size 4 <= [
        hash>alist alist>quot
    ] [
        (hash>quot)
    ] ifte ;

: default-tuple-method ( generic -- quot )
    #! If the generic does not define a specific method for a
    #! tuple, execute the return value of this.
    dup "methods" word-prop
    tuple over hash* dup [
        2nip cdr
    ] [
        drop object over hash* dup [
            2nip cdr
        ] [
            2drop [ dup tuple-delegate ] swap
            dup unit swap
            unit [ car ] cons [ undefined-method ] append
            \ ?ifte 3list append
        ] ifte
    ] ifte ;

: tuple-dispatch-quot ( generic -- quot )
    #! Generate a quotation that performs tuple class dispatch
    #! for methods defined on the given generic.
    dup default-tuple-method \ drop swons
    swap "methods" word-prop hash>quot
    [ dup class ] swap append ;

: add-tuple-dispatch ( word vtable -- )
    >r tuple-dispatch-quot tuple r> set-vtable ;

: clone-tuple ( tuple -- tuple )
    #! Make a shallow copy of a tuple, without cloning its
    #! delegate.
    dup array-capacity dup <tuple> [ -rot copy-array ] keep ;

: clone-delegate ( tuple -- )
    dup class "delegate-slot" word-prop dup [
        [ >fixnum slot clone ] 2keep set-slot
    ] [
        2drop
    ] ifte ;

M: tuple clone ( tuple -- tuple )
    #! Clone a tuple and its delegate.
    clone-tuple dup clone-delegate ;

: tuple>list ( tuple -- list )
    dup array-capacity swap array>list ;

M: tuple = ( obj tuple -- ? )
    over tuple? [
        over class over class = [
            swap tuple>list swap tuple>list =
        ] [
            2drop f
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: tuple hashcode ( vec -- n )
    dup array-capacity 1 number= [
        drop 0
    ] [
        1 swap array-nth hashcode
    ] ifte ;

tuple [
    ( generic vtable definition class -- )
    2drop add-tuple-dispatch
] "add-method" set-word-prop

tuple [
    drop tuple "builtin-type" word-prop unit
] "builtin-supertypes" set-word-prop

tuple 10 "priority" set-word-prop

tuple [ 2drop t ] "class<" set-word-prop
