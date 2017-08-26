! Copyright (C) 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel sequences splitting ;
IN: io.crlf

: crlf ( -- )
    "\r\n" write ;

: read-crlf ( -- seq )
    "\r" read-until
    [ char: \r assert= read1 char: \n assert= ] [ f like ] if* ;

: read-?crlf ( -- seq )
    "\r\n" read-until
    [ char: \r = [ read1 char: \n assert= ] when ] [ f like ] if* ;

: crlf>lf ( str -- str' )
    char: \r swap remove ;

: lf>crlf ( str -- str' )
    "\n" split "\r\n" join ;
