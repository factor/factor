! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel kernel.private math namespaces
make sequences strings words effects generic generic.standard
classes classes.algebra slots.private combinators accessors
words sequences.private assocs alien quotations hashtables ;
IN: slots

TUPLE: slot-spec name offset class initial read-only ;

PREDICATE: reader < word "reader" word-prop ;

PREDICATE: writer < word "writer" word-prop ;

: <slot-spec> ( -- slot-spec )
    slot-spec new
        object bootstrap-word >>class ;

: define-typecheck ( class generic quot props -- )
    [ dup define-simple-generic create-method ] 2dip
    [ [ props>> ] [ drop ] [ ] tri* update ]
    [ drop define ]
    3bi ;

: reader-quot ( slot-spec -- quot )
    [
        dup offset>> ,
        \ slot ,
        dup class>> object bootstrap-word eq?
        [ drop ] [ class>> 1array , \ declare , ] if
    ] [ ] make ;

: reader-word ( name -- word )
    ">>" append "accessors" create
    dup (( object -- value )) "declared-effect" set-word-prop
    dup t "reader" set-word-prop ;

: reader-props ( slot-spec -- assoc )
    [
        [ "reading" set ]
        [ read-only>> [ t "foldable" set ] when ] bi
        t "flushable" set
    ] H{ } make-assoc ;

: define-reader ( class slot-spec -- )
    [ name>> reader-word ] [ reader-quot ] [ reader-props ] tri
    define-typecheck ;

: writer-word ( name -- word )
    "(>>" ")" surround "accessors" create
    dup (( value object -- )) "declared-effect" set-word-prop
    dup t "writer" set-word-prop ;

ERROR: bad-slot-value value class ;

: writer-quot/object ( slot-spec -- )
    offset>> , \ set-slot , ;

: writer-quot/coerce ( slot-spec -- )
    [ class>> "coercer" word-prop [ dip ] curry % ]
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
    [ [ >fixnum ] dip ] % writer-quot/check ;

: writer-quot ( slot-spec -- quot )
    [
        {
            { [ dup class>> object bootstrap-word eq? ] [ writer-quot/object ] }
            { [ dup class>> "coercer" word-prop ] [ writer-quot/coerce ] }
            { [ dup class>> fixnum bootstrap-word class<= ] [ writer-quot/fixnum ] }
            [ writer-quot/check ]
        } cond
    ] [ ] make ;

: writer-props ( slot-spec -- assoc )
    "writing" associate ;

: define-writer ( class slot-spec -- )
    [ name>> writer-word ] [ writer-quot ] [ writer-props ] tri
    define-typecheck ;

: setter-word ( name -- word )
    ">>" prepend "accessors" create ;

: define-setter ( name -- )
    dup setter-word dup deferred? [
        [ \ over , swap writer-word , ] [ ] make
        (( object value -- object )) define-inline
    ] [ 2drop ] if ;

: changer-word ( name -- word )
    "change-" prepend "accessors" create ;

: define-changer ( name -- )
    dup changer-word dup deferred? [
        [
            \ over ,
            over reader-word 1quotation
            [ dip call ] curry [ dip swap ] curry %
            swap setter-word ,
        ] [ ] make (( object quot -- object )) define-inline
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
        [ reader-word define-simple-generic ]
        [ writer-word define-simple-generic ]
        [ define-setter ]
        [ define-changer ]
    } cleave ;

ERROR: no-initial-value class ;

GENERIC: initial-value* ( class -- object )

M: class initial-value* no-initial-value ;

: initial-value ( class -- object )
    {
        { [ \ f bootstrap-word over class<= ] [ f ] }
        { [ \ array-capacity bootstrap-word over class<= ] [ 0 ] }
        { [ float bootstrap-word over class<= ] [ 0.0 ] }
        { [ string bootstrap-word over class<= ] [ "" ] }
        { [ array bootstrap-word over class<= ] [ { } ] }
        { [ byte-array bootstrap-word over class<= ] [ B{ } ] }
        { [ simple-alien bootstrap-word over class<= ] [ <bad-alien> ] }
        { [ quotation bootstrap-word over class<= ] [ [ ] ] }
        [ dup initial-value* ]
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
        [ dup empty? ] [ peel-off-attributes ] until drop
    check-initial-value ;

M: slot-spec make-slot
    check-initial-value ;

: make-slots ( slots -- specs )
    [ make-slot ] map ;

: finalize-slots ( specs base -- specs )
    over length [ + ] with map [ >>offset ] 2map ;

: slot-named ( name specs -- spec/f )
    [ name>> = ] with find nip ;
