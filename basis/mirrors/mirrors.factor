! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences generic words
arrays classes slots slots.private classes.tuple
classes.tuple.private math vectors math.vectors quotations
accessors combinators byte-arrays specialized-arrays ;
IN: mirrors

TUPLE: mirror { object read-only } ;

C: <mirror> mirror

: object-slots ( mirror -- slots ) object>> class all-slots ; inline

M: mirror at*
    [ nip object>> ] [ object-slots slot-named ] 2bi
    dup [ offset>> slot t ] [ 2drop f f ] if ;

ERROR: no-such-slot slot ;
ERROR: read-only-slot slot ;

: check-set-slot ( val slot -- val offset )
    {
        { [ dup not ] [ no-such-slot ] }
        { [ dup read-only>> ] [ read-only-slot ] }
        { [ 2dup class>> instance? not ] [ class>> bad-slot-value ] }
        [ offset>> ]
    } cond ; inline

M: mirror set-at ( val key mirror -- )
    [ object-slots slot-named check-set-slot ] [ object>> ] bi
    swap set-slot ;

M: mirror delete-at ( key mirror -- )
    [ f ] 2dip set-at ;

M: mirror clear-assoc ( mirror -- )
    [ object>> ] [ object-slots ] bi [
        [ initial>> ] [ offset>> ] bi swapd set-slot
    ] with each ;

M: mirror >alist ( mirror -- alist )
    [ object-slots [ [ name>> ] map ] [ [ offset>> ] map ] bi ]
    [ object>> [ swap slot ] curry ] bi
    map zip ;

M: mirror assoc-size object>> layout-of second ;

INSTANCE: mirror assoc

MIXIN: enumerated-sequence
INSTANCE: array             enumerated-sequence
INSTANCE: vector            enumerated-sequence
INSTANCE: callable          enumerated-sequence
INSTANCE: byte-array        enumerated-sequence
INSTANCE: specialized-array enumerated-sequence
INSTANCE: simd-128          enumerated-sequence
INSTANCE: simd-256          enumerated-sequence

GENERIC: make-mirror ( obj -- assoc )
M: hashtable make-mirror ;
M: integer make-mirror drop f ;
M: enumerated-sequence make-mirror <enum> ;
M: object make-mirror <mirror> ;
