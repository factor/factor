! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: arrays errors hashtables kernel kernel-internals lists
math namespaces parser sequences sequences-internals strings
vectors words ;

! Tuples are really arrays in the runtime, but with a different
! type number. The layout is as follows:

! slot 0 - object header with type number (as usual)
! slot 1 - length, including class/delegate slots
! slot 2 - the class, a word
! slot 3 - the delegate tuple, or f

: class ( object -- class )
    dup tuple? [ 2 slot ] [ type type>class ] if ; inline

: class-tuple ( object -- class )
    dup tuple? [ 2 slot ] [ drop f ] if ; inline

: tuple-predicate ( word -- )
    #! Make a foo? word for testing the tuple class at the top
    #! of the stack.
    dup predicate-word
    [ \ class-tuple , over literalize , \ eq? , ] [ ] make
    define-predicate ;

: forget-tuple ( class -- )
    dup forget "predicate" word-prop car [ forget ] when* ;

: check-shape ( word slots -- )
    #! If the new list of slots is different from the previous,
    #! forget the old definition.
    >r in get lookup dup [
        dup "tuple-size" word-prop r> length 2 + =
        [ drop ] [ forget-tuple ] if
    ] [
        r> 2drop
    ] if ;

: delegate-slots { { 3 delegate set-delegate } } ;

: tuple-slots ( tuple slots -- )
    2dup "slot-names" set-word-prop
    2dup length 2 + "tuple-size" set-word-prop
    dupd 4 simple-slots
    2dup delegate-slots swap append "slots" set-word-prop
    define-slots ;

: tuple-constructor ( class -- word )
    word-name in get constructor-word dup save-location ;

PREDICATE: word tuple-class "tuple-size" word-prop ;

: check-tuple-class ( class -- )
    tuple-class? [ "Not a tuple class" throw ] unless ;

: define-constructor ( word class def -- )
    over check-tuple-class >r [
        dup literalize , "tuple-size" word-prop , \ make-tuple ,
    ] [ ] make r> append define-compound ;

: default-constructor ( tuple -- )
    [ tuple-constructor ] keep dup [
        "slots" word-prop 1 swap tail-slice reverse-slice
        [ peek unit , \ keep , ] each
    ] [ ] make define-constructor ;

: define-tuple ( tuple slots -- )
    2dup check-shape
    >r create-in
    dup intern-symbol
    dup tuple-predicate
    dup \ tuple bootstrap-word "superclass" set-word-prop
    dup define-class
    dup r> tuple-slots
    default-constructor ;

M: tuple clone ( tuple -- tuple )
    #! Clone a tuple and its delegate.
    (clone) dup delegate clone over set-delegate ;

M: tuple hashcode ( vec -- n )
    #! Poor.
    array-capacity ;

M: tuple = ( obj tuple -- ? )
    2dup eq? [
        2drop t
    ] [
        over tuple? [ array= ] [ 2drop f ] if
    ] if ;

: is? ( obj pred -- ? | pred: obj -- ? )
    #! Tests if the object satisfies the predicate, or if
    #! it delegates to an object satisfying it.
    [ call ] 2keep rot [
        2drop t
    ] [
        over [ >r delegate r> is? ] [ 2drop f ] if
    ] if ; inline

: array>tuple ( seq -- tuple )
    >vector dup first "tuple-size" word-prop over set-length
    >array (array>tuple) ;
