! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.tuple
classes.tuple.private combinators kernel math sequences sets
slots slots.private summary ;
IN: mirrors

TUPLE: mirror { object read-only } ;

C: <mirror> mirror

: object-slots ( mirror -- slots ) object>> class-of all-slots ; inline

M: mirror at*
    [ nip object>> ] [ object-slots slot-named ] 2bi
    [ offset>> slot t ] [ drop f f ] if* ;

ERROR: no-such-slot slot ;
ERROR: read-only-slot slot ;

: check-set-slot ( val slot -- val offset )
    {
        { [ dup not ] [ no-such-slot ] }
        { [ dup read-only>> ] [ read-only-slot ] }
        { [ 2dup class>> instance? not ] [ class>> bad-slot-value ] }
        [ offset>> ]
    } cond ; inline

M: mirror set-at
    [ object-slots slot-named check-set-slot ] [ object>> ] bi
    swap set-slot ;

ERROR: mirror-slot-removal slots mirror method ;

M: mirror delete-at
    \ delete-at mirror-slot-removal ;

M: mirror clear-assoc
    [ object-slots ] keep \ clear-assoc mirror-slot-removal ;

M: mirror-slot-removal summary
    drop "Slots cannot be removed from a tuple or a mirror of it" ;

M: mirror >alist
    [ object-slots ] [ object>> ] bi '[
        [ name>> ] [ offset>> _ swap slot ] bi
    ] map>alist ;

M: mirror keys
    object-slots [ name>> ] map ;

M: mirror values
    [ object-slots ] [ object>> ] bi
    '[ offset>> _ swap slot ] map ;

M: mirror assoc-size
    object>> class-of class-size ;

INSTANCE: mirror assoc

GENERIC: make-mirror ( obj -- assoc )
M: assoc make-mirror ;
M: set make-mirror members make-mirror ;
M: sequence make-mirror <enumerated> ;
M: object make-mirror <mirror> ;
