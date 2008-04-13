! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math strings sequences.private sequences strings
growable strings.private ;
IN: sbufs

<PRIVATE

: string>sbuf ( string length -- sbuf )
    sbuf boa ; inline

PRIVATE>

: <sbuf> ( n -- sbuf ) 0 <string> 0 string>sbuf ; inline

M: sbuf set-nth-unsafe
    underlying >r >r >fixnum r> >fixnum r> set-string-nth ;

M: sbuf new-sequence drop [ 0 <string> ] keep >fixnum string>sbuf ;

: >sbuf ( seq -- sbuf ) SBUF" " clone-like ; inline

M: sbuf like
    drop dup sbuf? [
        dup string? [ dup length string>sbuf ] [ >sbuf ] if
    ] unless ;

M: sbuf new-resizable drop <sbuf> ;

M: sbuf equal?
    over sbuf? [ sequence= ] [ 2drop f ] if ;

M: string new-resizable drop <sbuf> ;

M: string like
    drop dup string? [
        dup sbuf? [
            dup length over underlying length number= [
                underlying dup reset-string-hashcode
            ] [
                >string
            ] if
        ] [
            >string
        ] if
    ] unless ;

INSTANCE: sbuf growable
