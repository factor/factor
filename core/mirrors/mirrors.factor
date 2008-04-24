! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences generic words
arrays classes slots slots.private classes.tuple math vectors
quotations sorting prettyprint accessors ;
IN: mirrors

: all-slots ( class -- slots )
    superclasses [ "slots" word-prop ] map concat ;

: object-slots ( obj -- seq )
    class all-slots ;

TUPLE: mirror object slots ;

: <mirror> ( object -- mirror )
    dup object-slots mirror boa ;

ERROR: no-such-slot object name ;

ERROR: immutable-slot object name ;

M: mirror at*
    [ nip object>> ] [ slots>> slot-named ] 2bi
    dup [ offset>> slot t ] [ 2drop f f ] if ;

M: mirror set-at ( val key mirror -- )
    [ nip object>> ] [ drop ] [ slots>> slot-named ] 2tri dup [
        dup writer>> [
            nip offset>> set-slot
        ] [
            drop immutable-slot
        ] if
    ] [
        drop no-such-slot
    ] if ;

M: mirror delete-at ( key mirror -- )
    f -rot set-at ;

M: mirror >alist ( mirror -- alist )
    [ slots>> [ name>> ] map ]
    [ [ object>> ] [ slots>> ] bi [ offset>> slot ] with map ] bi
    zip ;

M: mirror assoc-size mirror-slots length ;

INSTANCE: mirror assoc

: sort-assoc ( assoc -- alist )
    >alist
    [ [ first unparse-short ] keep ] { } map>assoc
    sort-keys values ;

GENERIC: make-mirror ( obj -- assoc )
M: hashtable make-mirror sort-assoc ;
M: integer make-mirror drop f ;
M: array make-mirror <enum> ;
M: vector make-mirror <enum> ;
M: quotation make-mirror <enum> ;
M: object make-mirror <mirror> ;
