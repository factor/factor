! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: math  alien.c-types words kernel sequences alien.data accessors ;

IN: alien.c-types

GENERIC: make-c-array ( name -- <c-array> )

M: word make-c-array
    lookup-c-type
    dup sequence?
    [ [ second ] keep first <c-array> ]
    [ size>> uint <c-array> ]
    if
    ;

