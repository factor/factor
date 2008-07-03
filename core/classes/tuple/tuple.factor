! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel
kernel.private math namespaces sequences sequences.private
strings vectors words quotations memory combinators generic
classes classes.private slots.deprecated slots.private slots
compiler.units math.private accessors assocs ;
IN: classes.tuple

M: tuple class 1 slot 2 slot { word } declare ;

ERROR: not-a-tuple object ;

: check-tuple ( object -- tuple )
    dup tuple? [ not-a-tuple ] unless ; inline

ERROR: not-a-tuple-class class ;

: check-tuple-class ( class -- class )
    dup tuple-class? [ not-a-tuple-class ] unless ; inline

<PRIVATE

: tuple-layout ( class -- layout )
    check-tuple-class "layout" word-prop ;

: tuple-size ( tuple -- size )
    1 slot layout-size ; inline

: prepare-tuple>array ( tuple -- n tuple layout )
    check-tuple [ tuple-size ] [ ] [ 1 slot ] tri ;

: copy-tuple-slots ( n tuple -- array )
    [ array-nth ] curry map ;

PRIVATE>

: tuple>array ( tuple -- array )
    prepare-tuple>array
    >r copy-tuple-slots r>
    layout-class prefix ;

: tuple-slots ( tuple -- seq )
    prepare-tuple>array drop copy-tuple-slots ;

: slots>tuple ( tuple class -- array )
    tuple-layout <tuple> [
        [ tuple-size ] [ [ set-array-nth ] curry ] bi 2each
    ] keep ;

: >tuple ( tuple -- seq )
    unclip slots>tuple ;

: slot-names ( class -- seq )
    "slot-names" word-prop
    [ dup array? [ second ] when ] map ;

: all-slot-names ( class -- slots )
    superclasses [ slot-names ] map concat \ class prefix ;

ERROR: bad-superclass class ;

<PRIVATE

: tuple= ( tuple1 tuple2 -- ? )
    2dup [ 1 slot ] bi@ eq? [
        [ drop tuple-size ]
        [ [ [ drop array-nth ] [ nip array-nth ] 3bi = ] 2curry ]
        2bi all-integers?
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
    superclasses but-last-slice
    [ slot-names length ] sigma ;

: generate-tuple-slots ( class slots -- slot-specs )
    over superclass-size 2 + simple-slots ;

: define-tuple-slots ( class -- )
    dup dup "slot-names" word-prop generate-tuple-slots
    [ "slots" set-word-prop ]
    [ define-accessors ] ! new
    [ define-slots ] ! old
    2tri ;

: make-tuple-layout ( class -- layout )
    [ ]
    [ [ superclass-size ] [ slot-names length ] bi + ]
    [ superclasses dup length 1- ] tri
    <tuple-layout> ;

: define-tuple-layout ( class -- )
    dup make-tuple-layout "layout" set-word-prop ;

: compute-slot-permutation ( class old-slot-names -- permutation )
    >r all-slot-names r> [ index ] curry map ;

: apply-slot-permutation ( old-values permutation -- new-values )
    [ [ swap ?nth ] [ drop f ] if* ] with map ;

: permute-slots ( old-values -- new-values )
    dup first dup outdated-tuples get at
    compute-slot-permutation
    apply-slot-permutation ;

: change-tuple ( tuple quot -- newtuple )
    >r tuple>array r> call >tuple ; inline

: update-tuple ( tuple -- newtuple )
    [ permute-slots ] change-tuple ;

: update-tuples ( -- )
    outdated-tuples get
    dup assoc-empty? [ drop ] [
        [ >r class r> key? ] curry instances
        dup [ update-tuple ] map become
    ] if ;

[ update-tuples ] update-tuples-hook set-global

: update-tuples-after ( class -- )
    outdated-tuples get [ all-slot-names ] cache drop ;

M: tuple-class update-class
    [ define-tuple-layout ]
    [ define-tuple-slots ]
    [ define-tuple-predicate ]
    tri ;

: define-new-tuple-class ( class superclass slots -- )
    [ drop f f tuple-class define-class ]
    [ nip "slot-names" set-word-prop ]
    [ 2drop update-classes ]
    3tri ;

: subclasses ( class -- classes )
    class-usages [ tuple-class? ] filter ;

: each-subclass ( class quot -- )
    >r subclasses r> each ; inline

: redefine-tuple-class ( class superclass slots -- )
    [
        2drop
        [
            [ update-tuples-after ]
            [ +inlined+ changed-definition ]
            [ redefined ]
            tri
        ] each-subclass
    ]
    [ define-new-tuple-class ]
    3bi ;

: tuple-class-unchanged? ( class superclass slots -- ? )
    rot tuck [ superclass = ] [ slot-names = ] 2bi* and ;

: valid-superclass? ( class -- ? )
    [ tuple-class? ] [ tuple eq? ] bi or ;

: check-superclass ( superclass -- )
    dup valid-superclass? [ bad-superclass ] unless drop ;

PRIVATE>

GENERIC# define-tuple-class 2 ( class superclass slots -- )

M: word define-tuple-class
    over check-superclass
    define-new-tuple-class ;

M: tuple-class define-tuple-class
    3dup tuple-class-unchanged?
    [ over check-superclass 3dup redefine-tuple-class ] unless
    3drop ;

: define-error-class ( class superclass slots -- )
    [ define-tuple-class ] [ 2drop ] 3bi
    dup [ boa throw ] curry define ;

M: tuple-class reset-class
    [
        dup "slot-names" word-prop [
            [ reader-word method forget ]
            [ writer-word method forget ] 2bi
        ] with each
    ] [
        [ call-next-method ]
        [ { "layout" "slots" } reset-props ]
        bi
    ] bi ;

M: tuple-class rank-class drop 0 ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

M: tuple hashcode*
    [
        [ class hashcode ] [ tuple-size ] [ ] tri
        >r rot r> [
            swapd array-nth hashcode* sequence-hashcode-step
        ] 2curry each
    ] recursive-hashcode ;

! Deprecated
M: object get-slots ( obj slots -- ... )
    [ execute ] with each ;

M: object set-slots ( ... obj slots -- )
    <reversed> get-slots ;

: delegates ( obj -- seq ) [ delegate ] follow ;

: is? ( obj quot -- ? ) >r delegates r> contains? ; inline
