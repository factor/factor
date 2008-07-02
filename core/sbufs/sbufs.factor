! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math strings sequences.private sequences
strings growable strings.private ;
IN: sbufs

TUPLE: sbuf
{ underlying string }
{ length array-capacity } ;

: <sbuf> ( n -- sbuf ) 0 <string> 0 sbuf boa ; inline

M: sbuf set-nth-unsafe
    [ >fixnum ] [ >fixnum ] [ underlying>> ] tri* set-string-nth ;

M: sbuf new-sequence
    drop [ 0 <string> ] [ >fixnum ] bi sbuf boa ;

: >sbuf ( seq -- sbuf ) SBUF" " clone-like ; inline

M: sbuf like
    drop dup sbuf? [
        dup string? [ dup length sbuf boa ] [ >sbuf ] if
    ] unless ;

M: sbuf new-resizable drop <sbuf> ;

M: sbuf equal?
    over sbuf? [ sequence= ] [ 2drop f ] if ;

M: string new-resizable drop <sbuf> ;

M: string like
    drop dup string? [
        dup sbuf? [
            dup length over underlying>> length number= [
                underlying>> dup reset-string-hashcode
            ] [
                >string
            ] if
        ] [
            >string
        ] if
    ] unless ;

INSTANCE: sbuf growable
