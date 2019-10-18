! Copyright (C) 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel sequences ;
IN: io.crlf

: crlf ( -- )
    "\r\n" write ;

: read-crlf ( -- seq )
    "\r" read-until
    [ CHAR: \r assert= read1 CHAR: \n assert= ] [ f like ] if* ;
