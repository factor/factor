! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: words parser kernel namespaces lists strings math
hashtables errors sequences vectors ;

! Tuples are really arrays in the runtime, but with a different
! type number. The layout is as follows:

! slot 0 - object header with type number (as usual)
! slot 1 - length, including class/delegate slots
! slot 2 - the class, a word
! slot 3 - the delegate tuple, or f

: make-tuple ( class size -- tuple )
    #! Internal allocation function. Do not call it directly,
    #! since you can fool the runtime and corrupt memory by
    #! specifying an incorrect size.
    <tuple> [ 2 set-slot ] keep ;

: class-tuple 2 slot ; inline

IN: generic

DEFER: tuple?
BUILTIN: tuple 18 tuple? ;

M: tuple delegate 3 slot ;
M: tuple set-delegate 3 set-slot ;

: class ( obj -- class )
    #! The class of an object.
    dup tuple? [ class-tuple ] [ type builtin-type ] ifte ;

: tuple-predicate ( word -- )
    #! Make a foo? word for testing the tuple class at the top
    #! of the stack.
    dup predicate-word 2dup unit "predicate" set-word-prop
    swap [
        [ dup tuple? ] %
        [ \ class-tuple , literal, \ eq? , ] make-list ,
        [ drop f ] ,
        \ ifte ,
    ] make-list define-compound ;

: forget-tuple ( class -- )
    dup forget "predicate" word-prop car [ forget ] when* ;

: check-shape ( word slots -- )
    #! If the new list of slots is different from the previous,
    #! forget the old definition.
    >r "use" get search dup [
        dup "tuple-size" word-prop r> length 2 + =
        [ drop ] [ forget-tuple ] ifte
    ] [
        r> 2drop
    ] ifte ;

: tuple-slots ( tuple slots -- )
    2dup "slot-names" set-word-prop
    2dup length 2 + "tuple-size" set-word-prop
    dupd 4 simple-slots
    2dup { [ 3 delegate set-delegate ] } swap append
    "slots" set-word-prop
    define-slots ;

: define-constructor ( word def -- )
    >r [ word-name "in" get constructor-word ] keep [
        dup literal, "tuple-size" word-prop , \ make-tuple ,
    ] make-list r> append define-compound ;

: default-constructor ( tuple -- )
    dup [
        "slots" word-prop 1 swap tail-slice reverse-slice
        [ peek unit , \ keep , ] each
    ] make-list define-constructor ;

: define-tuple ( tuple slots -- )
    2dup check-shape
    >r create-in
    dup intern-symbol
    dup tuple-predicate
    dup tuple "metaclass" set-word-prop
    dup r> tuple-slots
    default-constructor ;

: alist>quot ( default alist -- quot )
    #! Turn an association list that maps values to quotations
    #! into a quotation that executes a quotation depending on
    #! the value on the stack.
    [
        [
            unswons
            \ dup , unswons literal, \ eq? , \ drop swons ,
            alist>quot , \ ifte ,
        ] make-list
    ] when* ;

: (hash>quot) ( default hash -- quot )
    [
        \ dup , \ hashcode , dup bucket-count , \ rem ,
        buckets>list [ alist>quot ] map-with >vector ,
        \ dispatch ,
    ] make-list ;

: hash>quot ( default hash -- quot )
    #! Turn a hash  table that maps values to quotations into a
    #! quotation that executes a quotation depending on the
    #! value on the stack.
    ( dup hash-size 4 <= ) t [
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
            2drop empty-method
        ] ifte
    ] ifte ;

: tuple-methods ( generic -- hash )
    #! A hashtable of methods on tuples.
    "methods" word-prop [ car metaclass tuple = ] hash-subset ;

: tuple-dispatch-quot ( generic -- quot )
    #! Generate a quotation that performs tuple class dispatch
    #! for methods defined on the given generic.
    dup default-tuple-method \ drop swons
    over tuple-methods hash>quot
    >r "picker" word-prop [ class-tuple ] r> append3 ;

: add-tuple-dispatch ( word vtable -- )
    >r tuple-dispatch-quot tuple r> set-vtable ;

! A sequence of all slots in a tuple, used for equality testing.
TUPLE: mirror tuple ;

C: mirror ( tuple -- mirror )
    over tuple? [
        [ set-mirror-tuple ] keep
    ] [
        "Not a tuple" throw
    ] ifte ;

M: mirror nth ( n mirror -- elt )
    bounds-check mirror-tuple array-nth ;

M: mirror set-nth ( n mirror -- elt )
    bounds-check mirror-tuple set-array-nth ;

M: mirror length ( mirror -- len )
    mirror-tuple array-capacity ;

: literal-tuple ( list -- tuple )
    dup first "tuple-size" word-prop <tuple>
    [ <mirror> swap copy-into ] keep ;

: clone-tuple ( tuple -- tuple )
    #! Make a shallow copy of a tuple, without cloning its
    #! delegate.
    [ array-capacity <tuple> dup ] keep copy-array ;

M: tuple clone ( tuple -- tuple )
    #! Clone a tuple and its delegate.
    clone-tuple dup delegate clone over set-delegate ;

M: tuple hashcode ( vec -- n )
    #! If the capacity is two, then all we have is the class
    #! slot and delegate.
    dup array-capacity 2 number= [
        drop 0
    ] [
        2 swap array-nth hashcode
    ] ifte ;

M: tuple = ( obj tuple -- ? )
    2dup eq? [
        2drop t
    ] [
        over tuple? [
            swap <mirror> swap <mirror> sequence=
        ] [
            2drop f
        ] ifte
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

PREDICATE: word tuple-class metaclass tuple = ;

: is? ( obj pred -- ? | pred: obj -- ? )
    #! Tests if the object satisfies the predicate, or if
    #! it delegates to an object satisfying it.
    [ call ] 2keep rot [
        2drop t
    ] [
        over [ >r delegate r> is? ] [ 2drop f ] ifte
    ] ifte ; inline
