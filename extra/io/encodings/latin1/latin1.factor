! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings kernel io.encodings.ascii.private ;
IN: io.encodings.latin1

TUPLE: latin1 ;

M: latin1 encode-char 
    256 encode-if< ;

M: latin1 decode-char
    drop stream-read1 ;
