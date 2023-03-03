! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
IN: classes.tuple
! for classes.union mutual dependency
DEFER: tuple-class?
<PRIVATE
DEFER: echelon-of
DEFER: layout-of
DEFER: layout-class-offset
DEFER: tuple-layout
PRIVATE>
USING: accessors arrays assocs classes classes.algebra
classes.algebra.private classes.builtin classes.private
combinators definitions effects generic kernel kernel.private
make math math.private memory namespaces quotations
sequences sequences.private slots slots.private strings words ;

<PRIVATE
PRIMITIVE: <tuple> ( layout -- tuple )
PRIMITIVE: <tuple-boa> ( slots... layout -- tuple )
PRIVATE>

PREDICATE: tuple-class < class
    "metaclass" word-prop tuple-class eq? ;

ERROR: too-many-slots class slots got max ;

: all-slots ( class -- slots )
    superclasses-of [ "slots" word-prop ] map concat ;

ERROR: no-slot name tuple ;

: ?offset-of-slot ( name tuple -- n/f )
    class-of all-slots slot-named [ offset>> ] [ f ] if* ;

: offset-of-slot ( name tuple -- n )
    2dup ?offset-of-slot [ 2nip ] [ no-slot ] if* ;

: get-slot-named ( name tuple -- value )
    [ nip ] [ offset-of-slot ] 2bi slot ;

: set-slot-named ( value name tuple -- )
    [ nip ] [ offset-of-slot ] 2bi set-slot ;

: set-slots ( assoc tuple -- )
    [ swapd set-slot-named ] curry assoc-each ; inline

: from-slots ( assoc class -- tuple )
    new [ set-slots ] keep ; inline

PREDICATE: immutable-tuple-class < tuple-class
    all-slots [ read-only>> ] all? ;

<PRIVATE

: tuple-layout ( class -- layout )
    "layout" word-prop ;

: layout-of ( tuple -- layout )
    1 slot { array } declare ; inline

M: tuple class-of layout-of 2 slot { word } declare ; inline

: tuple-size ( tuple -- size )
    layout-of 3 slot { fixnum } declare ; inline

: layout-up-to-date? ( object -- ? )
    dup tuple? [
        [ layout-of ] [ class-of tuple-layout ] bi eq?
    ] [ drop t ] if ;

: prepare-tuple-slots ( tuple -- n tuple )
    tuple check-instance [ tuple-size <iota> ] keep ;

: copy-tuple-slots ( n tuple -- array )
    [ array-nth ] curry map ;

: check-slots ( seq class -- seq class )
    [ ] [
        2dup all-slots [
            class>> 2dup instance?
            [ 2drop ] [ bad-slot-value ] if
        ] 2each
    ] if-bootstrapping ; inline

: pad-slots ( seq class -- seq' class )
    [ all-slots ] keep 2over 2length 2dup > [
        [ nip swap ] 2dip too-many-slots
    ] [
        drop [
            tail-slice [ [ initial>> ] map append ] unless-empty
        ] curry dip
    ] if ; inline

: make-tuple ( seq class -- tuple )
    tuple-layout <tuple> [
        [ tuple-size <iota> ]
        [ [ set-array-nth ] curry ]
        bi 2each
    ] keep ; inline

PRIVATE>

: tuple-slots ( tuple -- seq )
    prepare-tuple-slots copy-tuple-slots ;

GENERIC: slots>tuple ( seq class -- tuple )

M: tuple-class slots>tuple
    check-slots pad-slots make-tuple ;

: tuple>array ( tuple -- array )
    [ tuple-slots ] [ class-of prefix ] bi ;

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

GENERIC: final-class? ( object -- ? )

M: tuple-class final-class? "final" word-prop ;

M: builtin-class final-class? tuple eq? not ;

M: class final-class? drop t ;

M: object final-class? drop f ;

<PRIVATE

: tuple-predicate-quot/1 ( class -- quot )
    ! Fast path for tuples with no superclass
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
    superclasses-of [ "slots" word-prop length ] map-sum ;

: boa-check-quot ( class -- quot )
    all-slots [ class>> instance-check-quot ] map shallow-spread>quot
    f like ;

: define-boa-check ( class -- )
    dup boa-check-quot "boa-check" set-word-prop ;

: initial-values ( class -- seq )
    all-slots [ initial>> ] map ; inline

: tuple-prototype ( class -- prototype )
    [ initial-values ] keep over [ ] any?
    [ slots>tuple ] [ 2drop f ] if ;

: define-tuple-prototype ( class -- )
    dup tuple-prototype "prototype" set-word-prop ;

: prepare-slots ( slots superclass -- slots' )
    [ make-slots ] [ class-size 2 + ] bi* finalize-slots ;

: define-tuple-slots ( class -- )
    dup "slots" word-prop over superclass-of prepare-slots
    define-accessors ;

: make-tuple-layout ( class -- layout )
    [
        {
            [ , ]
            [ [ superclass-of class-size ] [ "slots" word-prop length ] bi + , ]
            [ superclasses-of length 1 - , ]
            [ superclasses-of [ [ , ] [ hashcode , ] bi ] each ]
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
    ] [ 3nip ] if ;

: apply-slot-permutation ( old-values triples -- new-values )
    [ first3 update-slot ] with map ;

SYMBOL: outdated-tuples

: permute-slots ( old-values layout -- new-values )
    [ first all-slots ] [ outdated-tuples get at ] bi
    compute-slot-permutation
    apply-slot-permutation ;

GENERIC: update-tuple ( tuple -- newtuple )

M: tuple update-tuple
    [ tuple-slots ] [ layout-of ] bi
    [ permute-slots ] [ first ] bi
    slots>tuple ;

: outdated-tuple? ( tuple assoc -- ? )
    [ [ layout-of ] dip key? ]
    [ drop class-of "forgotten" word-prop not ]
    2bi and ;

: update-tuples ( outdated-tuples -- )
    dup assoc-empty? [ drop ] [
        '[ dup tuple? [ _ outdated-tuple? ] [ drop f ] if ] instances
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
    [ 2drop update-classes ] 3tri ;

: subclasses ( class -- classes )
    class-usages [ tuple-class? ] filter ;

: each-subclass ( class quot -- )
    [ subclasses ] dip each ; inline

: redefine-tuple-class ( class superclass slots -- )
    [
        2drop
        [
            [ update-tuples-after ]
            [ changed-conditionally ]
            bi
        ] each-subclass
    ]
    [ define-new-tuple-class ] 3bi ;

: tuple-class-unchanged? ( class superclass slots -- ? )
    [ [ superclass-of ] [ bootstrap-word ] bi* = ]
    [ [ "slots" word-prop ] dip = ]
    bi-curry* bi and ;

: check-superclass ( superclass -- )
    dup final-class? [ bad-superclass ] when
    dup class? [ bad-superclass ] unless drop ;

GENERIC#: (define-tuple-class) 2 ( class superclass slots -- )

: thrower-effect ( slots -- effect )
    [ name>> ] map { "*" } <effect> ;

: error-slots ( slots -- slots' )
    [
        dup string? [ 1array ] when
        read-only swap remove
        read-only suffix
    ] map ;

: reset-final ( class -- )
    dup final-class? [
        [ "final" remove-word-prop ]
        [ changed-conditionally ]
        bi
    ] [ drop ] if ;

PRIVATE>

: define-tuple-class ( class superclass slots -- )
    over check-superclass
    over prepare-slots
    (define-tuple-class) ;

GENERIC: make-final ( class -- )

M: tuple-class make-final
    [ dup class-usage ?metaclass-changed ]
    [ t "final" set-word-prop ]
    bi ;

M: word (define-tuple-class)
    define-new-tuple-class ;

M: tuple-class (define-tuple-class)
    pick reset-final
    3dup tuple-class-unchanged?
    [ 2drop ?define-symbol ] [ redefine-tuple-class ] if ;

GENERIC: boa-effect ( class -- effect )

M: tuple-class boa-effect
    [ all-slots [ name>> ] map ] [ name>> 1array ] bi <effect> ;

: define-boa-word ( word class -- )
    tuple-class check-instance
    [ [ boa ] curry ] [ boa-effect ] bi
    define-inline ;

: forget-slot-accessors ( class slots -- )
    [
        name>>
        [ reader-word ?lookup-method forget ]
        [ writer-word ?lookup-method forget ] 2bi
    ] with each ;

M: tuple-class reset-class
    [
        dup "slots" word-prop forget-slot-accessors
    ] [
        [ call-next-method ]
        [ { "layout" "slots" "boa-check" "prototype" "final" } remove-word-props ]
        bi
    ] bi ;

M: tuple-class metaclass-changed
    ! Our superclass is no longer a tuple class, redefine with
    ! default superclass
    nip tuple over "slots" word-prop define-tuple-class ;

M: tuple-class rank-class drop 1 ;

M: tuple-class instance?
    dup echelon-of layout-class-offset tuple-instance? ;

M: tuple-class (flatten-class) , ;

M: tuple-class (classes-intersect?)
    {
        { [ over builtin-class? ] [ drop tuple eq? ] }
        { [ over tuple-class? ] [ [ class<= ] [ swap class<= ] 2bi or ] }
    } cond ;

M: tuple clone (clone) ; inline

M: tuple equal? over tuple? [ tuple= ] [ 2drop f ] if ;

: tuple-hashcode ( depth obj -- hash )
    [
        [ drop 1000003 ] dip
        [ class-of hashcode ] [ tuple-size ] bi
        [ dup fixnum+fast 82520 fixnum+fast ] [ <iota> ] bi
    ] 2keep [
        swapd array-nth hashcode* integer>fixnum rot fixnum-bitxor
        pick fixnum*fast [ [ fixnum+fast ] keep ] dip swap
    ] 2curry each drop nip 97531 fixnum+fast ; inline

M: tuple hashcode* [ tuple-hashcode ] recursive-hashcode ;

M: tuple-class new
    [ "prototype" word-prop ] [ (clone) ] [ tuple-layout <tuple> ] ?if ;

M: tuple-class boa
    [ "boa-check" word-prop [ call ] when* ]
    [ tuple-layout ]
    bi <tuple-boa> ;

M: tuple-class initial-value* new t ;
