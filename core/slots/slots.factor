! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays bit-arrays byte-arrays float-arrays kernel
kernel.private math namespaces sequences strings words effects
generic generic.standard classes classes.algebra slots.private
combinators accessors words ;
IN: slots

TUPLE: slot-spec name offset class initial read-only reader writer ;

: <slot-spec> ( -- slot-spec )
    slot-spec new
        object bootstrap-word >>class ;

: define-typecheck ( class generic quot -- )
    [
        dup define-simple-generic
        create-method
    ] dip define ;

: define-slot-word ( class offset word quot -- )
    rot >fixnum prefix define-typecheck ;

: create-accessor ( name effect -- word )
    >r "accessors" create dup r>
    "declared-effect" set-word-prop ;

: reader-quot ( decl -- quot )
    [
        \ slot ,
        dup object bootstrap-word eq?
        [ drop ] [ 1array , \ declare , ] if
    ] [ ] make ;

: reader-word ( name -- word )
    ">>" append (( object -- value )) create-accessor ;

: define-reader ( class slot-spec -- )
    [ offset>> ]
    [ name>> reader-word ]
    [ class>> reader-quot ]
    tri define-slot-word ;

: writer-word ( name -- word )
    "(>>" swap ")" 3append (( value object -- )) create-accessor ;

ERROR: bad-slot-value value object index ;

: writer-quot/object ( decl -- )
    drop \ set-slot , ;

: writer-quot/coerce ( decl -- )
    [ rot ] % "coercer" word-prop % [ -rot set-slot ] % ;

: writer-quot/check ( decl -- )
    \ pick ,
    "predicate" word-prop %
    [ [ set-slot ] [ bad-slot-value ] if ] % ;

: writer-quot/fixnum ( decl -- )
    [ rot >fixnum -rot ] % writer-quot/check ;

: writer-quot ( decl -- quot )
    [
        {
            { [ dup object bootstrap-word eq? ] [ writer-quot/object ] }
            { [ dup "coercer" word-prop ] [ writer-quot/coerce ] }
            { [ dup fixnum class<= ] [ writer-quot/fixnum ] }
            [ writer-quot/check ]
        } cond
    ] [ ] make ;

: define-writer ( class slot-spec -- )
    [ offset>> ]
    [ name>> writer-word ]
    [ class>> writer-quot ]
    tri define-slot-word ;

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
        { [ \ f over class<= ] [ f ] }
        { [ fixnum over class<= ] [ 0 ] }
        { [ float over class<= ] [ 0.0 ] }
        { [ array over class<= ] [ { } ] }
        { [ bit-array over class<= ] [ ?{ } ] }
        { [ byte-array over class<= ] [ B{ } ] }
        { [ float-array over class<= ] [ F{ } ] }
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
            { read-only: [ [ first >>read-only ] [ rest ] bi ] }
            [ bad-slot-attribute ]
        } case
    ] unless ;

ERROR: bad-initial-value name ;

: check-initial-value ( slot-spec -- slot-spec )
    dup initial>> [
        dup [ initial>> ] [ class>> ] bi instance?
        [ name>> bad-initial-value ] unless
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
