! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel
kernel.private math namespaces sequences sequences.private
strings vectors words quotations memory combinators generic
classes classes.private slots.deprecated slots.private slots
compiler.units math.private ;
IN: tuples

M: tuple delegate 2 slot ;

M: tuple set-delegate 2 set-slot ;

M: tuple class 1 slot 2 slot { word } declare ;

ERROR: no-tuple-class class ;

<PRIVATE

GENERIC: tuple-layout ( object -- layout )

M: class tuple-layout "layout" word-prop ;

M: tuple tuple-layout 1 slot ;

: tuple-size tuple-layout layout-size ; inline

PRIVATE>

: check-tuple ( class -- )
    dup tuple-class?
    [ drop ] [ no-tuple-class ] if ;

: tuple>array ( tuple -- array )
    dup tuple-layout
    [ layout-size swap [ array-nth ] curry map ] keep
    layout-class add* ;

: >tuple ( seq -- tuple )
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

! Predicate generation. We optimize at the expense of simplicity

: (tuple-predicate-quot) ( class -- quot )
    #! 4 slot == layout-superclasses
    #! 5 slot == layout-echelon
    [
        [ 1 slot dup 5 slot ] %
        dup tuple-layout layout-echelon ,
        [ fixnum>= ] %
        [
            dup tuple-layout layout-echelon ,
            [ swap 4 slot array-nth ] %
            literalize ,
            [ eq? ] %
        ] [ ] make ,
        [ drop f ] ,
        \ if ,
    ] [ ] make ;

: tuple-predicate-quot ( class -- quot )
    [
        [ dup tuple? ] %
        (tuple-predicate-quot) ,
        [ drop f ] ,
        \ if ,
    ] [ ] make ;

: define-tuple-predicate ( class -- )
    dup tuple-predicate-quot define-predicate ;

: superclass-size ( class -- n )
    superclasses 1 head-slice*
    [ "slot-names" word-prop length ] map sum ;

: generate-tuple-slots ( class slots -- slot-specs slot-names )
    over superclass-size 2 + simple-slots
    dup [ slot-spec-name ] map ;

: define-tuple-slots ( class slots -- )
    dupd generate-tuple-slots
    >r dupd "slots" set-word-prop
    r> dupd "slot-names" set-word-prop
    dup "slots" word-prop 2dup define-slots define-accessors ;

: make-tuple-layout ( class -- layout )
    dup superclass-size over "slot-names" word-prop length +
    over superclasses dup length 1- <tuple-layout> ;

: define-tuple-layout ( class -- )
    dup make-tuple-layout "layout" set-word-prop ;

: removed-slots ( class newslots -- seq )
    swap "slot-names" word-prop seq-diff ;

: forget-slots ( class newslots -- )
    dupd removed-slots [
        2dup
        reader-word forget-method
        writer-word forget-method
    ] with each ;

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

: tuple-class-unchanged ( class superclass slots -- ) 3drop ;

: prepare-tuple-class ( class slots -- )
    dupd define-tuple-slots
    dup define-tuple-layout
    define-tuple-predicate ;

: change-superclass "not supported" throw ;

: redefine-tuple-class ( class superclass slots -- )
    >r 2dup swap superclass eq?
    [ drop ] [ dupd change-superclass ] if r>
    2dup forget-slots
    2dup reshape-tuples
    over changed-word
    over redefined
    prepare-tuple-class ;

: define-new-tuple-class ( class superclass slots -- )
    >r dupd f swap tuple-class define-class r>
    prepare-tuple-class ;

PRIVATE>

: define-tuple-class ( class superclass slots -- )
    {
        { [ pick tuple-class? not ] [ define-new-tuple-class ] }
        { [ pick "slot-names" word-prop over = ] [ tuple-class-unchanged ] }
        { [ t ] [ redefine-tuple-class ] }
    } cond ;

: define-error-class ( class superclass slots -- )
    pick >r define-tuple-class r>
    dup [ construct-boa throw ] curry define ;

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
