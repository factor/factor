! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel kernel.private math
namespaces make sequences sequences.private strings vectors
words quotations memory combinators generic classes
classes.algebra classes.builtin classes.private slots.private
slots math.private accessors assocs effects ;
IN: classes.tuple

PREDICATE: tuple-class < class
    "metaclass" word-prop tuple-class eq? ;

ERROR: not-a-tuple object ;

: check-tuple ( object -- tuple )
    dup tuple? [ not-a-tuple ] unless ; inline

: all-slots ( class -- slots )
    superclasses [ "slots" word-prop ] map concat ;

PREDICATE: immutable-tuple-class < tuple-class ( class -- ? )
    all-slots [ read-only>> ] all? ;

<PRIVATE

: tuple-layout ( class -- layout )
    "layout" word-prop ;

: layout-of ( tuple -- layout )
    1 slot { array } declare ; inline

M: tuple class layout-of 2 slot { word } declare ;

: tuple-size ( tuple -- size )
    layout-of second ; inline

: prepare-tuple>array ( tuple -- n tuple layout )
    check-tuple [ tuple-size ] [ ] [ layout-of ] tri ;

: copy-tuple-slots ( n tuple -- array )
    [ array-nth ] curry map ;

: check-slots ( seq class -- seq class )
    [ ] [
        2dup all-slots [
            class>> 2dup instance?
            [ 2drop ] [ bad-slot-value ] if
        ] 2each
    ] if-bootstrapping ; inline

PRIVATE>

: initial-values ( class -- slots )
    all-slots [ initial>> ] map ;

: pad-slots ( slots class -- slots' class )
    [ initial-values over length tail append ] keep ; inline

: tuple>array ( tuple -- array )
    prepare-tuple>array
    [ copy-tuple-slots ] dip
    first prefix ;

: tuple-slots ( tuple -- seq )
    prepare-tuple>array drop copy-tuple-slots ;

GENERIC: slots>tuple ( seq class -- tuple )

M: tuple-class slots>tuple
    check-slots pad-slots
    tuple-layout <tuple> [
        [ tuple-size ]
        [ [ set-array-nth ] curry ]
        bi 2each
    ] keep ;

: >tuple ( seq -- tuple )
    unclip slots>tuple ;

ERROR: bad-superclass class ;

: tuple= ( tuple1 tuple2 -- ? )
    2dup [ tuple? ] both? [
        2dup [ layout-of ] bi@ eq? [
            [ drop tuple-size ]
            [ [ [ drop array-nth ] [ nip array-nth ] 3bi = ] 2curry ]
            2bi all-integers?
        ] [ 2drop f ] if
    ] [ 2drop f ] if ; inline

<PRIVATE

: tuple-predicate-quot/1 ( class -- quot )
    #! Fast path for tuples with no superclass
    [ ] curry [ layout-of 7 slot ] [ eq? ] surround 1quotation
    [ dup tuple? ] [ [ drop f ] if ] surround ;

: tuple-instance? ( object class offset -- ? )
    rot dup tuple? [
        layout-of
        2dup 1 slot fixnum<=
        [ swap slot eq? ] [ 3drop f ] if
    ] [ 3drop f ] if ; inline

: layout-class-offset ( echelon -- n )
    2 * 5 + ;

: tuple-predicate-quot ( class echelon -- quot )
    layout-class-offset [ tuple-instance? ] 2curry ;

: echelon-of ( class -- n )
    tuple-layout third ;

: define-tuple-predicate ( class -- )
    dup dup echelon-of {
        { 1 [ tuple-predicate-quot/1 ] }
        [ tuple-predicate-quot ]
    } case define-predicate ;

: class-size ( class -- n )
    superclasses [ "slots" word-prop length ] sigma ;

: (instance-check-quot) ( class -- quot )
    [
        \ dup ,
        [ "predicate" word-prop % ]
        [ [ literalize , \ bad-slot-value , ] [ ] make , ] bi
        \ unless ,
    ] [ ] make ;

: (fixnum-check-quot) ( class -- quot )
    (instance-check-quot) fixnum "coercer" word-prop prepend ;

: instance-check-quot ( class -- quot )
    {
        { [ dup object bootstrap-word eq? ] [ drop [ ] ] }
        { [ dup "coercer" word-prop ] [ "coercer" word-prop ] }
        { [ dup \ fixnum class<= ] [ (fixnum-check-quot) ] }
        [ (instance-check-quot) ]
    } cond ;

: boa-check-quot ( class -- quot )
    all-slots [ class>> instance-check-quot ] map spread>quot
    f like ;

: define-boa-check ( class -- )
    dup boa-check-quot "boa-check" set-word-prop ;

: tuple-prototype ( class -- prototype )
    [ initial-values ] keep
    over [ ] any? [ slots>tuple ] [ 2drop f ] if ;

: define-tuple-prototype ( class -- )
    dup tuple-prototype "prototype" set-word-prop ;

: prepare-slots ( slots superclass -- slots' )
    [ make-slots ] [ class-size 2 + ] bi* finalize-slots ;

: define-tuple-slots ( class -- )
    dup "slots" word-prop over superclass prepare-slots
    define-accessors ;

: make-tuple-layout ( class -- layout )
    [
        {
            [ , ]
            [ [ superclass class-size ] [ "slots" word-prop length ] bi + , ]
            [ superclasses length 1- , ]
            [ superclasses [ [ , ] [ hashcode , ] bi ] each ]
        } cleave
    ] { } make ;

: define-tuple-layout ( class -- )
    dup make-tuple-layout "layout" set-word-prop ;

: compute-slot-permutation ( new-slots old-slots -- triples )
    [ [ [ name>> ] map ] bi@ [ index ] curry map ]
    [ drop [ class>> ] map ]
    [ drop [ initial>> ] map ]
    2tri 3array flip ;

: update-slot ( old-values n class initial -- value )
    pick [
        [ [ swap nth dup ] dip instance? ] dip swap
        [ drop ] [ nip ] if
    ] [ [ 3drop ] dip ] if ;

: apply-slot-permutation ( old-values triples -- new-values )
    [ first3 update-slot ] with map ;

SYMBOL: outdated-tuples

: permute-slots ( old-values layout -- new-values )
    [ first all-slots ] [ outdated-tuples get at ] bi
    compute-slot-permutation
    apply-slot-permutation ;

: update-tuple ( tuple -- newtuple )
    [ tuple-slots ] [ layout-of ] bi
    [ permute-slots ] [ first ] bi
    slots>tuple ;

: outdated-tuple? ( tuple assoc -- ? )
    over tuple? [
        [ [ layout-of ] dip key? ]
        [ drop class "forgotten" word-prop not ]
        2bi and
    ] [ 2drop f ] if ;

: update-tuples ( -- )
    outdated-tuples get
    dup assoc-empty? [ drop ] [
        [ outdated-tuple? ] curry instances
        dup [ update-tuple ] map become
    ] if ;

: update-tuples-after ( class -- )
    [ all-slots ] [ tuple-layout ] bi outdated-tuples get set-at ;

M: tuple-class update-class
    {
        [ define-boa-check ]
        [ define-tuple-layout ]
        [ define-tuple-slots ]
        [ define-tuple-predicate ]
        [ define-tuple-prototype ]
    } cleave ;

: define-new-tuple-class ( class superclass slots -- )
    [ drop f f tuple-class define-class ]
    [ nip "slots" set-word-prop ]
    [ 2drop update-classes ]
    3tri ;

: subclasses ( class -- classes )
    class-usages [ tuple-class? ] filter ;

: each-subclass ( class quot -- )
    [ subclasses ] dip each ; inline

: redefine-tuple-class ( class superclass slots -- )
    [
        2drop
        [
            [ update-tuples-after ]
            [ changed-definition ]
            bi
        ] each-subclass
    ]
    [ define-new-tuple-class ] 3bi ;

: tuple-class-unchanged? ( class superclass slots -- ? )
    [ [ superclass ] [ bootstrap-word ] bi* = ]
    [ [ "slots" word-prop ] dip = ]
    bi-curry* bi and ;

: valid-superclass? ( class -- ? )
    [ tuple-class? ] [ tuple eq? ] bi or ;

: check-superclass ( superclass -- )
    dup valid-superclass? [ bad-superclass ] unless drop ;

GENERIC# (define-tuple-class) 2 ( class superclass slots -- )

PRIVATE>

: define-tuple-class ( class superclass slots -- )
    over check-superclass
    over prepare-slots
    (define-tuple-class) ;

M: word (define-tuple-class)
    define-new-tuple-class ;

M: tuple-class (define-tuple-class)
    3dup tuple-class-unchanged?
    [ 2drop ?define-symbol ] [ redefine-tuple-class ] if ;

: thrower-effect ( slots -- effect )
    [ dup array? [ first ] when ] map { "*" } <effect> ;

: define-error-class ( class superclass slots -- )
    [ define-tuple-class ]
    [ 2drop reset-generic ]
    [
        [ dup [ boa throw ] curry ]
        [ drop ]
        [ thrower-effect ]
        tri* define-declared
    ] 3tri ;

: boa-effect ( class -- effect )
    [ all-slots [ name>> ] map ] [ name>> 1array ] bi <effect> ;

: define-boa-word ( word class -- )
    [ [ boa ] curry ] [ boa-effect ] bi define-inline ;

M: tuple-class reset-class
    [
        dup "slots" word-prop [
            name>>
            [ reader-word method forget ]
            [ writer-word method forget ] 2bi
        ] with each
    ] [
        [ call-next-method ]
        [ { "layout" "slots" "boa-check" "prototype" } reset-props ]
        bi
    ] bi ;

M: tuple-class rank-class drop 0 ;

M: tuple-class instance?
    dup echelon-of layout-class-offset tuple-instance? ;

M: tuple-class (flatten-class) dup set ;

M: tuple-class (classes-intersect?)
    {
        { [ over tuple eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        { [ over tuple-class? ] [ [ class<= ] [ swap class<= ] 2bi or ] }
        [ swap classes-intersect? ]
    } cond ;

M: tuple clone (clone) ;

M: tuple equal? over tuple? [ tuple= ] [ 2drop f ] if ;

GENERIC: tuple-hashcode ( n tuple -- x )

M: tuple tuple-hashcode
    [
        [ class hashcode ] [ tuple-size ] [ ] tri
        [ rot ] dip [
            swapd array-nth hashcode* sequence-hashcode-step
        ] 2curry each
    ] recursive-hashcode ;

M: tuple hashcode* tuple-hashcode ;

M: tuple-class new
    dup "prototype" word-prop
    [ (clone) ] [ tuple-layout <tuple> ] ?if ;

M: tuple-class boa
    [ "boa-check" word-prop [ call ] when* ]
    [ tuple-layout ]
    bi <tuple-boa> ;

M: tuple-class initial-value* new ;
