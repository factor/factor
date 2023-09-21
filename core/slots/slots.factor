! Copyright (C) 2005, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays assocs byte-arrays classes
classes.algebra classes.algebra.private classes.maybe
combinators generic generic.standard hashtables kernel
kernel.private math quotations sequences sequences.private
strings words ;
IN: slots

<PRIVATE
PRIMITIVE: set-slot ( value obj n -- )
PRIMITIVE: slot ( obj m -- value )
PRIVATE>

TUPLE: slot-spec name offset class initial read-only ;

PREDICATE: reader < word "reader" word-prop ;

PREDICATE: reader-method < method "reading" word-prop >boolean ;

PREDICATE: writer < word "writer" word-prop ;

PREDICATE: writer-method < method "writing" word-prop >boolean ;

: <slot-spec> ( -- slot-spec )
    slot-spec new
        object bootstrap-word >>class ;

: define-typecheck ( class generic quot props -- )
    [ create-method ] 2dip
    [ [ props>> ] [ drop ] [ ] tri* assoc-union! drop ]
    [ drop define ]
    [ 2drop make-inline ]
    3tri ;

GENERIC#: reader-quot 1 ( class slot-spec -- quot )

M: object reader-quot
    nip [ offset>> [ slot ] curry ] [ class>> ] bi
    dup object bootstrap-word eq?
    [ drop ] [ 1array [ declare ] curry compose ] if ;

: reader-word ( name -- word )
    ">>" append "accessors" create-word
    dup t "reader" set-word-prop ;

: reader-props ( slot-spec -- assoc )
    "reading" associate ;

: define-reader-generic ( name -- )
    reader-word ( object -- value ) define-simple-generic ;

: define-reader ( class slot-spec -- )
    [ nip name>> define-reader-generic ]
    [
        {
            [ drop ]
            [ nip name>> reader-word ]
            [ reader-quot ]
            [ nip reader-props ]
        } 2cleave define-typecheck
    ] 2bi ;

: writer-word ( name -- word )
    "<<" append "accessors" create-word
    dup t "writer" set-word-prop ;

ERROR: bad-slot-value value class ;

: check-slot-value ( value slot -- )
    class>> 2dup instance? [ 2drop ] [ bad-slot-value ] if ; inline

GENERIC: instance-check-quot ( obj -- quot )

M: class instance-check-quot
    {
        { [ dup object bootstrap-word eq? ] [ drop [ ] ] }
        { [ dup "coercer" word-prop ] [ "coercer" word-prop ] }
        [ call-next-method ]
    } cond ;

M: object instance-check-quot
    [ predicate-def [ dup ] prepose ] keep
    [ bad-slot-value ] curry [ unless ] curry compose ;

GENERIC#: writer-quot 1 ( class slot-spec -- quot )

M: object writer-quot
    nip
    [ class>> instance-check-quot dup empty? [ [ dip ] curry ] unless ]
    [ offset>> [ set-slot ] curry ]
    bi append ;

: writer-props ( slot-spec -- assoc )
    "writing" associate ;

: define-writer-generic ( name -- )
    writer-word ( value object -- ) define-simple-generic ;

: define-writer ( class slot-spec -- )
    [ nip name>> define-writer-generic ] [
        {
            [ drop ]
            [ nip name>> writer-word ]
            [ writer-quot ]
            [ nip writer-props ]
        } 2cleave define-typecheck
    ] 2bi ;

: setter-word ( name -- word )
    ">>" prepend "accessors" create-word ;

: define-setter ( name -- )
    dup setter-word dup deferred? [
        swap writer-word 1quotation [ over ] prepose
        ( object value -- object ) define-inline
    ] [ 2drop ] if ;

: changer-word ( name -- word )
    "change-" prepend "accessors" create-word ;

: define-changer ( name -- )
    dup changer-word dup deferred? [
        over reader-word 1quotation
        [ dip call ] curry [ dip swap ] curry [ over ] prepose
        rot setter-word 1quotation compose
        ( object quot -- object ) define-inline
    ] [ 2drop ] if ;

: define-slot-methods ( class slot-spec -- )
    [ define-reader ]
    [
        dup read-only>> [ 2drop ] [
            [ name>> define-setter drop ]
            [ name>> define-changer drop ]
            [ define-writer ]
            2tri
        ] if
    ] 2bi ;

: define-accessors ( class specs -- )
    [ define-slot-methods ] with each ;

: define-protocol-slot ( name -- )
    {
        [ define-reader-generic ]
        [ define-writer-generic ]
        [ define-setter ]
        [ define-changer ]
    } cleave ;

DEFER: initial-value

GENERIC: initial-value* ( class -- object ? )

M: class initial-value* drop f f ;

M: maybe initial-value* drop f t ;

! Default initial value is f, 0, or the default initial value of
! the smallest class. Special case 0 because float is ostensibly
! smaller than integer in union{ integer float } because of
! alphabetical sorting.
M: anonymous-union initial-value*
    {
        { [ f over instance? ] [ drop f t ] }
        { [ 0 over instance? ] [ drop 0 t ] }
        [
            members>> sort-classes [ initial-value ] { } map>assoc
            ?last [ second t ] [ f f ] if*
        ]
    } cond ;

! See if any of the initial values fit the intersection class,
! or else return that none do, and leave it up to the user to
! provide an initial: value.
M: anonymous-intersection initial-value*
    {
        { [ f over instance? ] [ drop f t ] }
        { [ 0 over instance? ] [ drop 0 t ] }
        [
            [ ]
            [ participants>> sort-classes [ initial-value ] { } map>assoc ]
            [ ] tri

            [ [ first2 nip ] dip instance? ] curry find swap [
                nip second t
            ] [
                2drop f f
            ] if
        ]
    } cond ;

: initial-value ( class -- object ? )
    {
        { [ dup only-classoid? ] [ dup initial-value* ] }
        { [ dup "initial-value" word-prop ] [ dup "initial-value" word-prop t ] }
        { [ \ f bootstrap-word over class<= ] [ f t ] }
        { [ \ array-capacity bootstrap-word over class<= ] [ 0 t ] }
        { [ \ integer-array-capacity bootstrap-word over class<= ] [ 0 t ] }
        { [ bignum bootstrap-word over class<= ] [ 0 >bignum t ] }
        { [ float bootstrap-word over class<= ] [ 0.0 t ] }
        { [ string bootstrap-word over class<= ] [ "" t ] }
        { [ array bootstrap-word over class<= ] [ { } t ] }
        { [ byte-array bootstrap-word over class<= ] [ B{ } t ] }
        { [ pinned-alien bootstrap-word over class<= ] [ <bad-alien> t ] }
        { [ quotation bootstrap-word over class<= ] [ [ ] t ] }
        [ dup initial-value* ]
    } cond nipd ;

GENERIC: make-slot ( desc -- slot-spec )

M: string make-slot
    <slot-spec>
        swap >>name ;

: peel-off-name ( slot-spec array -- slot-spec array )
    [ first >>name ] [ rest ] bi ; inline

: init-slot-class ( slot-spec class -- slot-spec )
    [ >>class ] [ initial-value [ >>initial ] [ drop ] if ] bi ;

: peel-off-class ( slot-spec array -- slot-spec array )
    dup empty? [
        dup first classoid? [
            [ first init-slot-class ] [ rest ] bi
        ] when
    ] unless ;

ERROR: bad-slot-attribute key ;

: peel-off-attributes ( slot-spec array -- slot-spec array )
    dup empty? [
        unclip {
            { initial: [ [ first >>initial ] [ rest ] bi ] }
            { read-only [ [ t >>read-only ] dip ] }
            [ bad-slot-attribute ]
        } case
    ] unless ;

ERROR: bad-initial-value name initial-value class ;

: check-initial-value ( slot-spec -- slot-spec )
    [ ] [
        [ ] [ initial>> ] [ class>> ] tri
        2dup instance? [
            2drop
        ] [
            [ name>> ] 2dip bad-initial-value
        ] if
    ] if-bootstrapping ;

M: array make-slot
    <slot-spec>
        swap
        peel-off-name
        peel-off-class
        [ dup empty? ] [ peel-off-attributes ] until drop
    check-initial-value ;

M: slot-spec make-slot
    check-initial-value ;

: make-slots ( slots -- specs )
    [ make-slot ] map ;

: finalize-slots ( specs base -- specs )
    over length <iota> [ + ] with map [ >>offset ] 2map ;

: slot-named* ( name specs -- offset spec/f )
    [ name>> = ] with find ;

: slot-named ( name specs -- spec/f )
    slot-named* nip ;
