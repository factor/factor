! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.tuple classes.tuple.private
combinators fry hash-sets hashtables kernel math sequences sets slots
slots.private ;
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

M: mirror set-at ( val key mirror -- )
    [ object-slots slot-named check-set-slot ] [ object>> ] bi
    swap set-slot ;

M: mirror delete-at ( key mirror -- )
    [ f ] 2dip set-at ;

M: mirror clear-assoc ( mirror -- )
    [ object-slots ] [ object>> ] bi '[
        [ initial>> ] [ offset>> _ swap set-slot ] bi
    ] each ;

M: mirror >alist ( mirror -- alist )
    [ object-slots ] [ object>> ] bi '[
        [ name>> ] [ offset>> _ swap slot ] bi
    ] { } map>assoc ;

M: mirror keys ( mirror -- keys )
    object-slots [ name>> ] map ;

M: mirror values ( mirror -- values )
    [ object-slots ] [ object>> ] bi
    '[ offset>> _ swap slot ] map ;

M: mirror assoc-size
    object>> class-of class-size ;

INSTANCE: mirror assoc

GENERIC: make-mirror ( obj -- assoc )
M: hashtable make-mirror ;
M: hash-set make-mirror members make-mirror ;
M: integer make-mirror drop f ;
M: sequence make-mirror <enumerated> ;
M: object make-mirror <mirror> ;
