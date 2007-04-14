! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences generic words
arrays classes slots slots.private tuples math vectors
quotations sorting prettyprint ;
IN: mirrors

: all-slots ( class -- slots )
    superclasses [ "slots" word-prop ] map concat ;

: object-slots ( obj -- seq )
    class all-slots ;

TUPLE: mirror object slots ;

: <mirror> ( object -- mirror )
    dup object-slots mirror construct-boa ;

: >mirror< ( mirror -- obj slots )
    dup mirror-object swap mirror-slots ;

: mirror@ ( slot-name mirror -- obj slot-spec )
    >mirror< swapd slot-named ;

M: mirror at*
    mirror@ dup [ slot-spec-offset slot t ] [ 2drop f f ] if ;

M: mirror set-at ( val key mirror -- )
    mirror@ dup [
        dup slot-spec-writer [
            slot-spec-offset set-slot
        ] [
            "Immutable slot" throw
        ] if
    ] [
        "No such slot" throw
    ] if ;

M: mirror delete-at ( key mirror -- )
    f -rot set-at ;

M: mirror >alist ( mirror -- alist )
    >mirror<
    [ [ slot-spec-offset slot ] with map ] keep
    [ slot-spec-name ] map swap 2array flip ;

M: mirror assoc-size mirror-slots length ;

INSTANCE: mirror assoc

TUPLE: enum seq ;

C: <enum> enum

M: enum at*
    enum-seq 2dup bounds-check?
    [ nth t ] [ 2drop f f ] if ;

M: enum set-at enum-seq set-nth ;

M: enum delete-at enum-seq delete-nth ;

M: enum >alist ( enum -- alist )
    enum-seq dup length swap 2array flip ;

M: enum assoc-size enum-seq length ;

M: enum clear-assoc enum-seq delete-all ;

INSTANCE: enum assoc

: sort-assoc ( assoc -- alist )
    >alist
    [ dup first unparse-short swap ] { } map>assoc
    sort-keys values ;

GENERIC: make-mirror ( obj -- assoc )
M: hashtable make-mirror sort-assoc ;
M: integer make-mirror drop f ;
M: array make-mirror <enum> ;
M: vector make-mirror <enum> ;
M: quotation make-mirror <enum> ;
M: object make-mirror <mirror> ;
