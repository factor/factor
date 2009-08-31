! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.struct
classes.struct.prettyprint.private classes.tuple
classes.tuple.private combinators generic hashtables kernel
math quotations sequences slots slots.private vectors words ;
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

GENERIC: make-mirror ( obj -- assoc )
M: hashtable make-mirror ;
M: integer make-mirror drop f ;
M: array make-mirror <enum> ;
M: vector make-mirror <enum> ;
M: quotation make-mirror <enum> ;
M: object make-mirror <mirror> ;
M: struct make-mirror struct>assoc [ [ [ name>> ] [ class>> ] bi 2array ] dip ] assoc-map ;
