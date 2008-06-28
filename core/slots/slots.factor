! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math namespaces
sequences strings words effects generic generic.standard
classes slots.private combinators accessors ;
IN: slots

TUPLE: slot-spec type name offset reader writer ;

C: <slot-spec> slot-spec

: define-typecheck ( class generic quot -- )
    [
        dup define-simple-generic
        create-method
    ] dip define ;

: define-slot-word ( class slot word quot -- )
    rot >fixnum prefix define-typecheck ;

: reader-quot ( decl -- quot )
    [
        \ slot ,
        dup object bootstrap-word eq?
        [ drop ] [ 1array , \ declare , ] if
    ] [ ] make ;

: create-accessor ( name effect -- word )
    >r "accessors" create dup r>
    "declared-effect" set-word-prop ;

: reader-word ( name -- word )
    ">>" append (( object -- value )) create-accessor ;

: define-reader ( class slot name decl -- )
    [ reader-word ] dip reader-quot define-slot-word ;

: writer-word ( name -- word )
    "(>>" swap ")" 3append (( value object -- )) create-accessor ;

ERROR: bad-slot-value value object index ;

: writer-quot ( decl -- quot )
    [
        dup object bootstrap-word eq?
        [ drop \ set-slot , ] [
            \ pick ,
            "predicate" word-prop %
            [ [ set-slot ] [ bad-slot-value ] if ] %
        ] if
    ] [ ] make ;

: define-writer ( class slot name decl -- )
    [ writer-word ] dip writer-quot define-slot-word ;

: setter-word ( name -- word )
    ">>" prepend (( object value -- object )) create-accessor ;

: define-setter ( name -- )
    dup setter-word dup deferred? [
        [ \ over , swap writer-word , ] [ ] make define-inline
    ] [ 2drop ] if ;

: changer-word ( name -- word )
    "change-" prepend (( object quot -- object )) create-accessor ;

: define-changer ( name -- )
    dup changer-word dup deferred? [
        [
            [ over >r >r ] %
            over reader-word ,
            [ r> call r> swap ] %
            swap setter-word ,
        ] [ ] make define-inline
    ] [ 2drop ] if ;

: define-slot-methods ( class slot-spec -- )
    {
        [ [ drop ] [ name>> ] bi* define-changer ]
        [ [ drop ] [ name>> ] bi* define-setter ]
        [ [ offset>> ] [ name>> ] [ type>> ] tri define-reader ]
        [ [ offset>> ] [ name>> ] [ type>> ] tri define-writer ]
    } 2cleave ;

: define-accessors ( class specs -- )
    [ define-slot-methods ] with each ;

: slot-named ( name specs -- spec/f )
    [ slot-spec-name = ] with find nip ;
