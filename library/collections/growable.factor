! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! Some low-level code used by vectors and string buffers.
IN: sequences-internals
USING: errors kernel kernel-internals math math-internals
sequences ;

GENERIC: underlying
GENERIC: set-underlying
GENERIC: set-fill

: capacity ( seq -- n ) underlying length ; inline

: expand ( len seq -- )
    [ underlying resize ] keep set-underlying ;

: new-size ( n -- n ) 3 * dup 50 < [ drop 50 ] when ;

: ensure ( n seq -- )
    2dup length >= [
        >r 1+ r>
        2dup capacity > [ over new-size over expand ] when
        2dup set-fill
    ] when 2drop ;

TUPLE: bounds-error index seq ;

: bounds-error <bounds-error> throw ;

: growable-check ( n seq -- n seq )
    over 0 < [ bounds-error ] when ; inline

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

: grow-length ( len seq -- )
    growable-check 2dup capacity > [ 2dup expand ] when set-fill ;

: clone-growable ( obj -- obj )
    (clone) dup underlying clone over set-underlying ;
