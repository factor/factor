! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays errors hashtables kernel kernel-internals
math namespaces parser sequences sequences-internals strings
vectors words ;

IN: kernel-internals

: class-tuple ( object -- class )
    dup tuple? [ 2 slot ] [ drop f ] if ; inline

: tuple= ( tuple tuple -- ? )
    2dup [ array-capacity ] 2apply number= [
        dup array-capacity
        [ 2dup swap array-nth >r pick array-nth r> = ] all? 2nip
    ] [
        2drop f
    ] if ;

IN: generic

: class ( object -- class )
    dup tuple? [ 2 slot ] [ type type>class ] if ; inline

: tuple-predicate ( word -- )
    dup predicate-word
    [ \ class-tuple , over literalize , \ eq? , ] [ ] make
    define-predicate ;

: forget-tuple ( class -- )
    dup forget "predicate" word-prop first [ forget ] when* ;

: check-shape ( word slots -- )
    >r in get lookup dup [
        dup "tuple-size" word-prop r> length 2 + =
        [ drop ] [ forget-tuple ] if
    ] [
        r> 2drop
    ] if ;

: delegate-slots { { 3 object delegate set-delegate } } ;

: tuple-slots ( tuple slots -- )
    2dup "slot-names" set-word-prop
    2dup length 2 + "tuple-size" set-word-prop
    dupd 4 simple-slots
    2dup delegate-slots swap append "slots" set-word-prop
    define-slots ;

PREDICATE: word tuple-class "tuple-size" word-prop ;

: check-tuple-class ( class -- )
    tuple-class? [ "Not a tuple class" throw ] unless ;

: define-constructor ( word class def -- )
    pick reset-generic
    swap dup check-tuple-class [
        dup literalize ,
        "tuple-size" word-prop ,
        \ <tuple> , %
    ] [ ] make define-compound ;

: default-constructor ( tuple -- )
    [ create-constructor ] keep
    dup "slots" word-prop unclip drop <reversed>
    [ [ tuck ] swap peek add ] map concat >quotation
    define-constructor ;

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
    (clone) dup delegate clone over set-delegate ;

M: tuple hashcode ( tuple -- n ) class hashcode ;

M: tuple = ( obj tuple -- ? )
    2dup eq?
    [ 2drop t ] [ over tuple? [ tuple= ] [ 2drop f ] if ] if ;

: is? ( obj pred -- ? | pred: obj -- ? )
    over [
        2dup >r >r call
        [ r> r> 2drop t ] [ r> delegate r> is? ] if
    ] [
        2drop f 
    ] if ; inline

: >tuple ( seq -- tuple )
    >vector dup first "tuple-size" word-prop over set-length
    >array array>tuple ;
