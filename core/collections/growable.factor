! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! Some low-level code used by vectors and string buffers.
IN: sequences-internals
USING: errors kernel kernel-internals math math-internals
sequences ;

GENERIC: underlying ( seq -- underlying )
GENERIC: set-underlying ( underlying seq -- )
GENERIC: set-fill ( n seq -- )

: capacity ( seq -- n ) underlying length ; inline

: expand ( len seq -- )
    [ underlying resize ] keep set-underlying ; inline

: contract ( len seq -- )
    swap over length [
        0 pick pick swap set-nth-unsafe
    ] (repeat) drop ;

: new-size ( old -- new ) 1+ 3 * ; inline

: ensure ( n seq -- )
    2dup length >= [
        >r 1+ r>
        2dup capacity > [ over new-size over expand ] when
        2dup set-fill
    ] when 2drop ; inline

: growable-check ( n seq -- n seq )
    >r >fixnum r> over 0 fixnum< [ bounds-error ] when ; inline

: grow-length ( n seq -- )
    growable-check
    2dup length < [ 2dup contract ] when
    2dup capacity > [ 2dup expand ] when
    set-fill ; inline

: clone-resizable ( seq -- newseq )
    (clone) dup underlying clone over set-underlying ; inline
