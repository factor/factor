! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Some low-level code used by vectors and string buffers.
IN: kernel-internals
USING: errors kernel math math-internals sequences ;

GENERIC: underlying
GENERIC: set-underlying
GENERIC: set-capacity

: expand ( len seq -- )
    [ underlying resize ] keep set-underlying ;

: ensure ( n seq -- )
    #! If n is beyond the sequence's length, increase the length,
    #! growing the underlying storage if necessary, with an
    #! optimistic doubling of its size.
    2dup length fixnum>= [
        >r 1 fixnum+ r>
        2dup underlying length fixnum> [
            over 2 fixnum* over expand
        ] when
        set-capacity
    ] [
        2drop
    ] ifte ;

: grow-length ( len seq -- )
    growable-check 2dup length > [ 2dup expand ] when
    set-capacity ;
