! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private
sequences sequences.private ;
IN: growable

MIXIN: growable

SLOT: length
SLOT: underlying

M: growable length length>> ; inline
M: growable nth-unsafe underlying>> nth-unsafe ; inline
M: growable set-nth-unsafe underlying>> set-nth-unsafe ; inline

: capacity ( seq -- n ) underlying>> length ; inline

: expand ( len seq -- )
    [ resize ] change-underlying drop ; inline

GENERIC: contract ( len seq -- )

M: growable contract ( len seq -- )
    [ length ] keep
    [ [ 0 ] 2dip set-nth-unsafe ] curry
    (each-integer) ; inline

: growable-check ( n seq -- n seq )
    over 0 < [ bounds-error ] when ; inline

M: growable set-length ( n seq -- )
    growable-check
    2dup length < [
        2dup contract
    ] [
        2dup capacity > [ 2dup expand ] when
    ] if
    (>>length) ;

: new-size ( old -- new ) 1 + 3 * ; inline

: ensure ( n seq -- n seq )
    growable-check
    2dup length >= [
        2dup capacity >= [ over new-size over expand ] when
        [ >fixnum ] dip
        over 1 fixnum+fast over (>>length)
    ] [
        [ >fixnum ] dip
    ] if ; inline

M: growable set-nth ensure set-nth-unsafe ; inline

M: growable clone (clone) [ clone ] change-underlying ; inline

M: growable lengthen ( n seq -- )
    2dup length > [
        2dup capacity > [ over new-size over expand ] when
        2dup (>>length)
    ] when 2drop ; inline

M: growable shorten ( n seq -- )
    growable-check
    2dup length < [
        2dup contract
        2dup (>>length)
    ] when 2drop ; inline

M: growable new-resizable new-sequence 0 over set-length ; inline

INSTANCE: growable sequence
