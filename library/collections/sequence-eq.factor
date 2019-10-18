! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: kernel kernel-internals lists math strings vectors ;

! Note that the sequence union does not include lists, or user
! defined tuples that respond to the sequence protocol.
UNION: sequence array string sbuf vector ;

: length= ( seq seq -- ? ) length swap length number= ;

: sequence= ( seq seq -- ? )
    #! Check if two sequences have the same length and elements,
    #! but not necessarily the same class.
    2dup length= [
        dup length [ >r 2dup r> 2nth = ] all? 2nip
    ] [
        2drop f
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
