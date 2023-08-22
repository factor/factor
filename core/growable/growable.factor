! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.private sequences
sequences.private ;
IN: growable

MIXIN: growable

SLOT: length
SLOT: underlying

M: growable length length>> ; inline
M: growable nth-unsafe underlying>> nth-unsafe ; inline
M: growable set-nth-unsafe underlying>> set-nth-unsafe ; inline

<PRIVATE

: push-unsafe ( elt seq -- )
    [ length integer>fixnum-strict ] keep
    [ set-nth-unsafe ] [ [ 1 fixnum+fast ] dip length<< ] 2bi ; inline

: push-all-unsafe ( from to src dst -- )
    [ over - swap ] 2dip pickd [ length integer>fixnum-strict ] keep
    [ [ fixnum+fast ] dip length<< ] 2keep <copier> (copy) drop ; inline

PRIVATE>

: capacity ( seq -- n ) underlying>> length ; inline

: expand ( len seq -- )
    [ resize ] change-underlying drop ; inline

GENERIC: contract ( len seq -- )

M: growable contract
    [ length ] keep
    [ [ 0 ] 2dip set-nth-unsafe ] curry
    each-integer-from ; inline

M: growable set-length
    bounds-check-head
    2dup length < [
        2dup contract
    ] [
        2dup capacity > [ 2dup expand ] when
    ] if
    length<< ;

: new-size ( old -- new ) 1 + 2 * ; inline

: ensure ( n seq -- n seq )
    bounds-check-head
    2dup length >= [
        2dup capacity >= [ over new-size over expand ] when
        [ integer>fixnum-strict ] dip
        over 1 fixnum+fast >>length
    ] [
        [ integer>fixnum-strict ] dip
    ] if ; inline

M: growable set-nth ensure set-nth-unsafe ; inline

M: growable clone (clone) [ clone ] change-underlying ; inline

M: growable lengthen
    2dup length > [
        2dup capacity > [ over new-size over expand ] when
        2dup length<<
    ] when 2drop ; inline

M: growable shorten
    bounds-check-head
    2dup length < [
        2dup contract
        2dup length<<
    ] when 2drop ; inline

M: growable new-resizable new-sequence 0 over set-length ; inline

INSTANCE: growable sequence
