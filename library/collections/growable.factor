! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Some low-level code used by vectors and string buffers.
IN: sequences-internals
USING: errors kernel kernel-internals math math-internals
sequences ;

GENERIC: underlying
GENERIC: set-underlying

! fill pointer mutation. user code should use set-length
! instead, since it will also resize the underlying sequence.
GENERIC: set-fill

: capacity ( seq -- n ) underlying length ; inline

: expand ( len seq -- )
    [ underlying resize ] keep set-underlying ;

: new-size ( n -- n )
    3 fixnum* dup 50 fixnum< [ drop 50 ] when ;

: ensure ( n seq -- )
    #! If n is beyond the sequence's length, increase the length,
    #! growing the underlying storage if necessary, with an
    #! optimistic doubling of its size.
    2dup length fixnum>= [
        >r 1 fixnum+ r>
        2dup capacity fixnum>
        [ over new-size over expand ] when
        2dup set-fill
    ] when 2drop ;

: grow-length ( len seq -- )
    growable-check 2dup capacity > [ 2dup expand ] when set-fill ;

: clone-growable ( obj -- obj )
    #! Cloning vectors, sbufs, hashtables.
    (clone) dup underlying clone over set-underlying ;
