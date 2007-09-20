! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors
namespaces ;
IN: io.encodings

TUPLE: encode-error ;

: encode-error ( -- * ) \ encode-error construct-empty throw ;

TUPLE: decode-error ;

: decode-error ( -- * ) \ decode-error construct-empty throw ;

SYMBOL: begin

: decoded ( buf ch -- buf ch state )
    over push 0 begin ;

: finish-decoding ( buf ch state -- str )
    begin eq? [ decode-error ] unless drop { } like ;

: decode ( seq quot -- str )
    >r [ length <vector> 0 begin ] keep r> each
    finish-decoding ; inline
