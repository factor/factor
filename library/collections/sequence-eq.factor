! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: kernel kernel-internals lists math strings vectors ;

! Note that the sequence union does not include lists, or user
! defined tuples that respond to the sequence protocol.
UNION: sequence array string sbuf vector ;

: length= ( seq seq -- ? ) length swap length number= ;

: (sequence=) ( seq seq i -- ? )
    over length over number= [
        3drop t
    ] [
        3dup 2nth = [ 1 + (sequence=) ] [ 3drop f ] ifte
    ] ifte ;

: sequence= ( seq seq -- ? )
    #! Check if two sequences have the same length and elements,
    #! but not necessarily the same class.
    over general-list? over general-list? or [
        swap >list swap >list =
    ] [
        2dup length= [ 0 (sequence=) ] [ 2drop f ] ifte
    ] ifte ; flushable

M: sequence = ( obj seq -- ? )
    2dup eq? [
        2drop t
    ] [
        over type over type eq? [ sequence= ] [ 2drop f ] ifte
    ] ifte ;

M: string = ( obj str -- ? )
    over string? [
        over hashcode over hashcode number=
        [ sequence= ] [ 2drop f ] ifte
    ] [
        2drop f
    ] ifte ;
