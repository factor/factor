! Copyright (C) 2024 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple kernel math
namespaces sequences sequences.private slots.private ;

IN: deep-clone

<PRIVATE

SYMBOL: cloned

GENERIC: (deep-clone) ( object -- object' )

: (?deep-clone) ( object -- object' )
    cloned get [ (deep-clone) ] cache ;

M: object (deep-clone)
    (clone) [
        dup class-of all-slots [
            offset>> [ slot (?deep-clone) ] [ set-slot ] 2bi
        ] with each
    ] keep ;

M: array (deep-clone)
    call-next-method dup length over '[
        _
        [ array-nth (?deep-clone) ]
        [ set-array-nth ] 2bi
    ] each-integer ;

PRIVATE>

: deep-clone ( object -- object' )
    H{ } clone cloned [ (deep-clone) ] with-variable ;
