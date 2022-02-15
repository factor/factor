! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: growable
MIXIN: growable ! for bootstrap
USING: accessors kernel layouts math math.private sequences
sequences.private ;

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
    [ [ fixnum+fast ] dip length<< ] 2keep <copy> (copy) drop ; inline

PRIVATE>

: capacity ( seq -- n ) underlying>> length ; inline

: expand ( len seq -- )
    [ resize ] change-underlying drop ; inline

GENERIC: contract ( len seq -- )

M: growable contract
    [ length ] keep
    [ [ 0 ] 2dip set-nth-unsafe ] curry
    (each-integer) ; inline

M: growable set-length
    bounds-check-head
    2dup length < [
        2dup contract
    ] [
        2dup capacity > [ 2dup expand ] when
    ] if
    length<< ;

: new-size ( old -- new )
    integer>fixnum-strict 1 fixnum+fast 2 fixnum*fast
    dup 0 < [ drop most-positive-fixnum ] when ; inline

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
