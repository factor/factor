! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel
kernel.private math namespaces sequences sequences.private
strings vectors words quotations memory combinators generic
classes classes.private slots slots.private ;
IN: tuples

M: tuple delegate 3 slot ;

M: tuple set-delegate 3 set-slot ;

M: tuple class class-of-tuple ;

<PRIVATE

: tuple= ( tuple1 tuple2 -- ? )
    over array-capacity over array-capacity dup -rot number= [
        -rot
        [ >r over r> array-nth >r array-nth r> = ] 2curry
        all-integers?
    ] [
        3drop f
    ] if ;

: tuple-class-eq? ( obj class -- ? )
    over tuple? [ swap 2 slot eq? ] [ 2drop f ] if ; inline

: permutation ( seq1 seq2 -- permutation )
    swap [ index ] curry map ;

: reshape-tuple ( oldtuple permutation -- newtuple )
    >r tuple>array 2 cut r>
    [ [ swap ?nth ] [ drop f ] if* ] curry* map
    append (>tuple) ;

: reshape-tuples ( class newslots -- )
    >r dup [ swap class eq? ] curry instances dup
    rot "slot-names" word-prop r> permutation
    [ reshape-tuple ] curry map become ;

: old-slots ( class newslots -- seq )
    swap "slots" word-prop 1 tail-slice
    [ slot-spec-name swap member? not ] curry* subset ;

: forget-slots ( class newslots -- )
    dupd old-slots [
        2dup
        slot-spec-reader 2array forget
        slot-spec-writer 2array forget
    ] curry* each ;

: check-shape ( class newslots -- )
    over tuple-class? [
        over "slot-names" word-prop over = [
            2dup forget-slots
            2dup reshape-tuples
            over redefined
        ] unless
    ] when 2drop ;

GENERIC: tuple-size ( class -- size ) foldable

M: tuple-class tuple-size "slot-names" word-prop length 2 + ;

PRIVATE>

: define-tuple-predicate ( class -- )
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
    dup tuple-class?
    [ drop ] [ \ check-tuple construct-boa throw ] if ;

: define-tuple-class ( class slots -- )
    2dup check-shape
    over f tuple tuple-class define-class
    over define-tuple-predicate
    define-tuple-slots ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

: (delegates) ( obj -- )
    [ dup , delegate (delegates) ] when* ;

: delegates ( obj -- seq )
    [ dup ] [ [ delegate ] keep ] { } unfold ;

: is? ( obj quot -- ? ) >r delegates r> contains? ; inline

: >tuple ( seq -- tuple )
    >vector dup first tuple-size over set-length
    >array (>tuple) ;

M: tuple hashcode*
    [
        dup array-capacity -rot 0 -rot [
            swapd array-nth hashcode* bitxor
        ] 2curry reduce
    ] recursive-hashcode ;

: tuple-slots ( tuple -- seq ) tuple>array 2 tail ;

! Definition protocol
M: tuple-class reset-class
    {
        "metaclass" "superclass" "slot-names" "slots"
    } reset-props ;

M: object get-slots ( obj slots -- ... )
    [ execute ] curry* each ;

M: object set-slots ( ... obj slots -- )
    <reversed> get-slots ;

M: object construct-empty ( class -- tuple )
    dup tuple-size <tuple> ;

M: object construct ( ... slots class -- tuple )
    construct-empty [ swap set-slots ] keep ;

M: object construct-boa ( ... class -- tuple )
    dup tuple-size <tuple-boa> ;
