! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel
kernel.private math namespaces sequences sequences.private
strings vectors words quotations memory combinators generic
classes classes.private slots slots.deprecated slots.private
compiler.units ;
IN: tuples

M: tuple delegate 2 slot ;

M: tuple set-delegate 2 set-slot ;

M: tuple class 1 slot 2 slot { word } declare ;

ERROR: no-tuple-class class ;

<PRIVATE

: tuple-size tuple-layout layout-size ; inline

PRIVATE>

: check-tuple ( class -- )
    dup tuple-class?
    [ drop ] [ no-tuple-class ] if ;

: tuple>array ( tuple -- array )
    dup tuple-layout
    [ layout-size swap [ array-nth ] curry map ] keep
    layout-class add* ;

: >tuple ( sequence -- tuple )
    dup first tuple-layout <tuple> [
        >r 1 tail-slice dup length r>
        [ tuple-size min ] keep
        [ set-array-nth ] curry
        2each
    ] keep ;

<PRIVATE

: tuple= ( tuple1 tuple2 -- ? )
    over tuple-layout over tuple-layout eq? [
        dup tuple-size -rot
        [ >r over r> array-nth >r array-nth r> = ] 2curry
        all-integers?
    ] [
        2drop f
    ] if ;

: permutation ( seq1 seq2 -- permutation )
    swap [ index ] curry map ;

: reshape-tuple ( oldtuple permutation -- newtuple )
    >r tuple>array 2 cut r>
    [ [ swap ?nth ] [ drop f ] if* ] with map
    append >tuple ;

: reshape-tuples ( class newslots -- )
    >r dup "slot-names" word-prop r> permutation
    [
        >r [ swap class eq? ] curry instances dup r>
        [ reshape-tuple ] curry map
        become
    ] 2curry after-compilation ;

: old-slots ( class newslots -- seq )
    swap "slots" word-prop 1 tail-slice
    [ slot-spec-name swap member? not ] with subset ;

: forget-slots ( class newslots -- )
    dupd old-slots [
        2dup
        slot-spec-reader 2array forget
        slot-spec-writer 2array forget
    ] with each ;

: check-shape ( class newslots -- )
    over tuple-class? [
        over "slot-names" word-prop over = [
            2dup forget-slots
            2dup reshape-tuples
            over changed-word
            over redefined
        ] unless
    ] when 2drop ;

M: tuple-class tuple-layout "layout" word-prop ;

: define-tuple-predicate ( class -- )
    dup tuple-layout
    [ over tuple? [ swap 1 slot eq? ] [ 2drop f ] if ] curry
    define-predicate ;

: delegate-slot-spec
    T{ slot-spec f
        object
        "delegate"
        2
        delegate
        set-delegate
    } ;

: define-tuple-slots ( class slots -- )
    dupd 3 simple-slots
    2dup [ slot-spec-name ] map "slot-names" set-word-prop
    2dup delegate-slot-spec add* "slots" set-word-prop
    2dup define-slots
    define-accessors ;

: define-tuple-layout ( class -- )
    dup
    dup "slot-names" word-prop length 1+ { } 0 <tuple-layout>
    "layout" set-word-prop ;

PRIVATE>

: define-tuple-class ( class slots -- )
    2dup check-shape
    over f tuple tuple-class define-class
    dupd define-tuple-slots
    dup define-tuple-layout
    define-tuple-predicate ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

: delegates ( obj -- seq )
    [ dup ] [ [ delegate ] keep ] [ ] unfold nip ;

: is? ( obj quot -- ? ) >r delegates r> contains? ; inline

M: tuple hashcode*
    [
        dup tuple-size -rot 0 -rot [
            swapd array-nth hashcode* bitxor
        ] 2curry reduce
    ] recursive-hashcode ;

: tuple-slots ( tuple -- seq ) tuple>array 2 tail ;

! Definition protocol
M: tuple-class reset-class
    {
        "metaclass" "superclass" "slot-names" "slots" "layout"
    } reset-props ;

M: object get-slots ( obj slots -- ... )
    [ execute ] with each ;

M: object set-slots ( ... obj slots -- )
    <reversed> get-slots ;

M: object construct-empty ( class -- tuple )
    tuple-layout <tuple> ;

M: object construct ( ... slots class -- tuple )
    construct-empty [ swap set-slots ] keep ;

M: object construct-boa ( ... class -- tuple )
    tuple-layout <tuple-boa> ;
