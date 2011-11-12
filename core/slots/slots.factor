! Copyright (C) 2005, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel kernel.private math namespaces
make sequences strings effects generic generic.standard
classes classes.algebra slots.private combinators accessors
words sequences.private assocs alien quotations hashtables ;
IN: slots

TUPLE: slot-spec name offset class initial read-only ;

PREDICATE: reader < word "reader" word-prop ;

PREDICATE: reader-method < method "reading" word-prop ;

PREDICATE: writer < word "writer" word-prop ;

PREDICATE: writer-method < method "writing" word-prop ;

: <slot-spec> ( -- slot-spec )
    slot-spec new
        object bootstrap-word >>class ;

: define-typecheck ( class generic quot props -- )
    [ create-method ] 2dip
    [ [ props>> ] [ drop ] [ ] tri* assoc-union! drop ]
    [ drop define ]
    [ 2drop make-inline ]
    3tri ;

GENERIC# reader-quot 1 ( class slot-spec -- quot )

M: object reader-quot 
    nip [
        dup offset>> ,
        \ slot ,
        dup class>> object bootstrap-word eq?
        [ drop ] [ class>> 1array , \ declare , ] if
    ] [ ] make ;

: reader-word ( name -- word )
    ">>" append "accessors" create
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
    "<<" append "accessors" create
    dup t "writer" set-word-prop ;

ERROR: bad-slot-value value class ;

: (instance-check-quot) ( class -- quot )
    [
        \ dup ,
        [ "predicate" word-prop % ]
        [ [ bad-slot-value ] curry , ] bi
        \ unless ,
    ] [ ] make ;

: instance-check-quot ( class -- quot )
    {
        { [ dup object bootstrap-word eq? ] [ drop [ ] ] }
        { [ dup "coercer" word-prop ] [ "coercer" word-prop ] }
        { [ dup integer bootstrap-word eq? ] [ drop [ >integer ] ] }
        [ (instance-check-quot) ]
    } cond ;

GENERIC# writer-quot 1 ( class slot-spec -- quot )

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
    ">>" prepend "accessors" create ;

: define-setter ( name -- )
    dup setter-word dup deferred? [
        [ \ over , swap writer-word , ] [ ] make
        ( object value -- object ) define-inline
    ] [ 2drop ] if ;

: changer-word ( name -- word )
    "change-" prepend "accessors" create ;

: define-changer ( name -- )
    dup changer-word dup deferred? [
        [
            \ over ,
            over reader-word 1quotation
            [ dip call ] curry [ ] like [ dip swap ] curry %
            swap setter-word ,
        ] [ ] make ( object quot -- object ) define-inline
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

GENERIC: initial-value* ( class -- object ? )

M: class initial-value* drop f f ;

: initial-value ( class -- object ? )
    {
        { [ dup "initial-value" word-prop ] [ dup "initial-value" word-prop t ] }
        { [ \ f bootstrap-word over class<= ] [ f t ] }
        { [ \ array-capacity bootstrap-word over class<= ] [ 0 t ] }
        { [ float bootstrap-word over class<= ] [ 0.0 t ] }
        { [ string bootstrap-word over class<= ] [ "" t ] }
        { [ array bootstrap-word over class<= ] [ { } t ] }
        { [ byte-array bootstrap-word over class<= ] [ B{ } t ] }
        { [ pinned-alien bootstrap-word over class<= ] [ <bad-alien> t ] }
        { [ quotation bootstrap-word over class<= ] [ [ ] t ] }
        [ dup initial-value* ]
    } cond [ drop ] 2dip ;

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
        dup first class? [
            [ first init-slot-class ]
            [ rest ]
            bi
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

ERROR: bad-initial-value name ;

: check-initial-value ( slot-spec -- slot-spec )
    [ ] [
        dup [ initial>> ] [ class>> ] bi instance?
        [ name>> bad-initial-value ] unless
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
    over length iota [ + ] with map [ >>offset ] 2map ;

: slot-named* ( name specs -- offset spec/f )
    [ name>> = ] with find ;

: slot-named ( name specs -- spec/f )
    slot-named* nip ;

! Predefine some slots, because there are change-* words in other vocabs
! that nondeterministically cause ambiguities when USEd alongside
! accessors

SLOT: at
SLOT: nth
SLOT: global
