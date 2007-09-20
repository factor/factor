! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! Some low-level code used by vectors and string buffers.
USING: kernel kernel.private math math.private
sequences sequences.private ;
IN: growable

MIXIN: growable
GENERIC: underlying ( seq -- underlying )
GENERIC: set-underlying ( underlying seq -- )
GENERIC: set-fill ( n seq -- )

M: growable nth-unsafe underlying nth-unsafe ;

M: growable set-nth-unsafe underlying set-nth-unsafe ;

: capacity ( seq -- n ) underlying length ; inline

: expand ( len seq -- )
    [ underlying resize ] keep set-underlying ; inline

: contract ( len seq -- )
    [ length ] keep
    [ 0 -rot set-nth-unsafe ] curry
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
    >r >fixnum r> set-fill ;

: new-size ( old -- new ) 1+ 3 * ; inline

: ensure ( n seq -- n seq )
    growable-check
    2dup length >= [
        2dup capacity >= [ over new-size over expand ] when
        >r >fixnum r>
        2dup >r 1 fixnum+fast r> set-fill
    ] [
        >r >fixnum r>
    ] if ; inline

M: growable set-nth ensure set-nth-unsafe ;

M: growable clone ( seq -- newseq )
    (clone) dup underlying clone over set-underlying ;

M: growable lengthen ( n seq -- )
    2dup length > [
        2dup capacity > [ over new-size over expand ] when
        2dup >r >fixnum r> set-fill
    ] when 2drop ;

INSTANCE: growable sequence
