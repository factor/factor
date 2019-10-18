! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sbufs
USING: kernel math strings kernel-internals sequences-internals
sequences strings ;

: <sbuf> ( n -- sbuf )
    0 <string> string>sbuf 0 over set-fill ; inline

M: sbuf set-length grow-length ;

M: sbuf nth-unsafe underlying nth-unsafe ;

M: sbuf nth bounds-check nth-unsafe ;

M: sbuf set-nth-unsafe
    underlying >r >r >fixnum r> >fixnum r> set-char-slot ;

M: sbuf set-nth growable-check 2dup ensure set-nth-unsafe ;

M: sbuf clone clone-resizable ;

M: sbuf new drop dup <sbuf> tuck set-length ;

: >sbuf ( seq -- sbuf ) SBUF" " clone-like ; inline

M: sbuf like
    drop dup sbuf? [
        dup string? [ string>sbuf ] [ >sbuf ] if
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
