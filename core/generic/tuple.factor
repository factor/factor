! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays definitions errors hashtables kernel
kernel-internals math namespaces sequences
sequences-internals strings vectors words quotations memory ;

IN: kernel-internals

: tuple= ( tuple1 tuple2 -- ? )
    2dup [ array-capacity ] 2apply number= [
        dup array-capacity
        [ 2dup swap array-nth >r pick array-nth r> = ] all? 2nip
    ] [
        2drop f
    ] if ;

: tuple-class-eq? ( obj class -- ? )
    over tuple? [ swap 2 slot eq? ] [ 2drop f ] if ; inline

: permutation ( oldslots newslots -- permutation )
    [ swap index ] map-with ;

: reshape-tuple ( oldtuple permutation -- newtuple )
    >r tuple>array 2 swap cut r>
    [ [ swap nth ] [ drop f ] if* ] map-with
    append (>tuple) ;

: reshape-tuples ( class newslots -- old new )
    >r dup "predicate" word-prop instances dup
    rot "slot-names" word-prop r> permutation
    swap [ swap reshape-tuple ] map-with become ;

: forget-slots ( class -- )
    dup "slots" word-prop 1 tail-slice [
        2dup
        slot-spec-reader 2array forget
        slot-spec-writer 2array forget
    ] each-with ;

: check-shape ( class newslots -- )
    over tuple-class? [
        over forget-slots
        over "slot-names" word-prop over =
        [ 2drop ] [ reshape-tuples ] if
    ] [
        2drop
    ] if ;

IN: generic

: class ( object -- class )
    dup tuple? [ 2 slot ] [ type type>class ] if ; inline

: tuple-predicate ( class -- )
    dup predicate-word
    over [ tuple-class-eq? ] curry
    define-predicate ;

: delegate-slot-spec
    T{ slot-spec f
        object
        "delegate"
        3
        delegate
        set-delegate
    } ;

: define-tuple-slots ( class slots -- )
    2dup "slot-names" set-word-prop
    dupd 4 simple-slots
    2dup delegate-slot-spec add* "slots" set-word-prop
    define-slots ;

TUPLE: check-tuple class ;

: check-tuple ( class -- )
    dup tuple-class? [ drop ] [ <check-tuple> throw ] if ;

: make-constructor ( class def -- quot )
    >r dup tuple-size [ <tuple> ] curry curry r> append ;

: save-constructor ( word class def -- )
    >r dupd "constructing" set-word-prop r>
    "constructor-quot" set-word-prop ;

: define-constructor ( word class def -- )
    [ make-constructor define-inline ] 3keep
    save-constructor ;

: default-constructor-quot ( class -- quot )
    [
        "slots" word-prop 1 tail-slice <reversed>
        [ \ tuck , slot-spec-writer , ] each
    ] [ ] make ;

: create-constructor ( class -- word )
    dup word-name swap word-vocabulary constructor-word
    dup reset-generic ;

: default-constructor ( class -- )
    dup create-constructor 2dup "constructor" set-word-prop
    swap dup default-constructor-quot define-constructor ;

: define-tuple-class ( class slots -- )
    2dup check-shape
    >r dup tuple-predicate
    \ tuple bootstrap-word over set-superclass
    dup define-class
    dup r> define-tuple-slots
    default-constructor ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

: (delegates) ( obj -- )
    [ dup , delegate (delegates) ] when* ;

: delegates ( obj -- seq ) [ (delegates) ] { } make ;

: is? ( obj quot -- ? ) >r delegates r> contains? ; inline

: >tuple ( seq -- tuple )
    >vector dup first tuple-size over set-length >array (>tuple) ;

M: tuple hashcode*
    [
        0 over array-capacity [
            pick array-nth >r pick r> hashcode* bitxor
        ] each 2nip
    ] recursive-hashcode ;

: tuple-slots ( tuple -- seq ) tuple>array 2 tail ;

! Definition protocol
M: tuple-class forget
    dup "constructor" word-prop forget forget-class ;

PREDICATE: compound constructor
    "constructor-quot" word-prop >boolean ;

M: constructor definer drop \ C: \ ; ;

M: constructor definition "constructor-quot" word-prop ;
