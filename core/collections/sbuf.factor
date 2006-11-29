! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: strings
USING: kernel math strings sequences-internals sequences ;

: <sbuf> ( n -- sbuf )
    0 <string> string>sbuf 0 over set-fill ;

M: sbuf set-length grow-length ;
M: sbuf nth-unsafe underlying nth-unsafe ;
M: sbuf nth bounds-check nth-unsafe ;
M: sbuf set-nth-unsafe underlying set-nth-unsafe ;
M: sbuf set-nth growable-check 2dup ensure set-nth-unsafe ;
M: sbuf clone clone-resizable ;
M: sbuf new drop <sbuf> ;
: >sbuf ( seq -- sbuf ) [ sbuf? ] [ <sbuf> ] >sequence ; inline

M: sbuf like
    drop dup sbuf? [
        dup string? [ string>sbuf ] [ >sbuf ] if
    ] unless ;
