! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel kernel.private math namespaces
sequences strings words effects generic generic.standard classes
classes.algebra slots.private combinators accessors words
sequences.private assocs alien ;
IN: slots

TUPLE: slot-spec name offset class initial read-only reader writer ;

: <slot-spec> ( -- slot-spec )
    slot-spec new
        object bootstrap-word >>class ;

: define-typecheck ( class generic quot props -- )
    [ dup define-simple-generic create-method ] 2dip
    [ [ props>> ] [ drop ] [ [ t ] H{ } map>assoc ] tri* update ]
    [ drop define ]
    3bi ;

: create-accessor ( name effect -- word )
    >r "accessors" create dup r>
    "declared-effect" set-word-prop ;

: reader-quot ( slot-spec -- quot )
    [
        dup offset>> ,
        \ slot ,
        dup class>> object bootstrap-word eq?
        [ drop ] [ class>> 1array , \ declare , ] if
    ] [ ] make ;

: reader-word ( name -- word )
    ">>" append (( object -- value )) create-accessor ;

: reader-props ( slot-spec -- seq )
    read-only>> { "foldable" "flushable" } { "flushable" } ? ;

: define-reader ( class slot-spec -- )
    [ name>> reader-word ] [ reader-quot ] [ reader-props ] tri
    define-typecheck ;

: writer-word ( name -- word )
    "(>>" swap ")" 3append (( value object -- )) create-accessor ;

ERROR: bad-slot-value value class ;

: writer-quot/object ( slot-spec -- )
    offset>> , \ set-slot , ;

: writer-quot/coerce ( slot-spec -- )
    [ \ >r , class>> "coercer" word-prop % \ r> , ]
    [ offset>> , \ set-slot , ]
    bi ;

: writer-quot/check ( slot-spec -- )
    [ offset>> , ]
    [
        \ pick ,
        dup class>> "predicate" word-prop %
        [ set-slot ] ,
        class>> [ 2nip bad-slot-value ] curry [ ] like ,
        \ if ,
    ]
    bi ;

: writer-quot/fixnum ( slot-spec -- )
    [ >r >fixnum r> ] % writer-quot/check ;

: writer-quot ( slot-spec -- quot )
    [
        {
            { [ dup class>> object bootstrap-word eq? ] [ writer-quot/object ] }
            { [ dup class>> "coercer" word-prop ] [ writer-quot/coerce ] }
            { [ dup class>> fixnum bootstrap-word class<= ] [ writer-quot/fixnum ] }
            [ writer-quot/check ]
        } cond
    ] [ ] make ;

: define-writer ( class slot-spec -- )
    [ name>> writer-word ] [ writer-quot ] bi { } define-typecheck ;

: setter-word ( name -- word )
    ">>" prepend (( object value -- object )) create-accessor ;

: define-setter ( slot-spec -- )
    name>> dup setter-word dup deferred? [
        [ \ over , swap writer-word , ] [ ] make define-inline
    ] [ 2drop ] if ;

: changer-word ( name -- word )
    "change-" prepend (( object quot -- object )) create-accessor ;

: define-changer ( slot-spec -- )
    name>> dup changer-word dup deferred? [
        [
            [ over >r >r ] %
            over reader-word ,
            [ r> call r> swap ] %
            swap setter-word ,
        ] [ ] make define-inline
    ] [ 2drop ] if ;

: define-slot-methods ( class slot-spec -- )
    [ define-reader ]
    [
        dup read-only>> [ 2drop ] [
            [ define-setter drop ]
            [ define-changer drop ]
            [ define-writer ]
            2tri
        ] if
    ] 2bi ;

: define-accessors ( class specs -- )
    [ define-slot-methods ] with each ;

: define-protocol-slot ( name -- )
    {
        [ reader-word drop ]
        [ writer-word drop ]
        [ setter-word drop ]
        [ changer-word drop ]
    } cleave ;

ERROR: no-initial-value class ;

: initial-value ( class -- object )
    {
        { [ \ f bootstrap-word over class<= ] [ f ] }
        { [ \ array-capacity bootstrap-word over class<= ] [ 0 ] }
        { [ float bootstrap-word over class<= ] [ 0.0 ] }
        { [ string bootstrap-word over class<= ] [ "" ] }
        { [ array bootstrap-word over class<= ] [ { } ] }
        { [ byte-array bootstrap-word over class<= ] [ B{ } ] }
        { [ simple-alien bootstrap-word over class<= ] [ <bad-alien> ] }
        [ no-initial-value ]
    } cond nip ;

GENERIC: make-slot ( desc -- slot-spec )

M: string make-slot
    <slot-spec>
        swap >>name ;

: peel-off-name ( slot-spec array -- slot-spec array )
    [ first >>name ] [ rest ] bi ; inline

: peel-off-class ( slot-spec array -- slot-spec array )
    dup empty? [
        dup first class? [
            [ first >>class ] [ rest ] bi
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
    dup initial>> [
        [ ] [
            dup [ initial>> ] [ class>> ] bi instance?
            [ name>> bad-initial-value ] unless
        ] if-bootstrapping
    ] [
        dup class>> initial-value >>initial
    ] if ;

M: array make-slot
    <slot-spec>
        swap
        peel-off-name
        peel-off-class
        [ dup empty? not ] [ peel-off-attributes ] [ ] while drop
    check-initial-value ;

: make-slots ( slots base -- specs )
    over length [ + ] with map
    [ [ make-slot ] dip >>offset ] 2map ;

: slot-named ( name specs -- spec/f )
    [ slot-spec-name = ] with find nip ;
