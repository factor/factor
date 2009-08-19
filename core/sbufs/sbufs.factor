! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences.private sequences
strings growable strings.private ;
IN: sbufs

TUPLE: sbuf
{ underlying string }
{ length array-capacity } ;

: <sbuf> ( n -- sbuf ) 0 <string> 0 sbuf boa ; inline

M: sbuf set-nth-unsafe
    [ >fixnum ] [ >fixnum ] [ underlying>> ] tri* set-string-nth ; inline

M: sbuf new-sequence
    drop [ 0 <string> ] [ >fixnum ] bi sbuf boa ; inline

: >sbuf ( seq -- sbuf ) SBUF" " clone-like ; inline

M: sbuf like
    drop dup sbuf? [
        dup string? [ dup length sbuf boa ] [ >sbuf ] if
    ] unless ; inline

M: sbuf new-resizable drop <sbuf> ; inline

M: sbuf equal?
    over sbuf? [ sequence= ] [ 2drop f ] if ;

M: string new-resizable drop <sbuf> ; inline

M: string like
    #! If we have a string, we're done.
    #! If we have an sbuf, and it's at full capacity, we're done.
    #! Otherwise, call resize-string, which is a relatively
    #! fast primitive.
    drop dup string? [
        dup sbuf? [
            [ length ] [ underlying>> ] bi
            2dup length eq?
            [ nip dup reset-string-hashcode ] [ resize-string ] if
        ] [ >string ] if
    ] unless ; inline

INSTANCE: sbuf growable
