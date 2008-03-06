! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings strings kernel io.encodings.ascii sequences math ;
IN: io.encodings.latin1

TUPLE: latin1 ;

M: latin1 stream-write-encoded 
    drop 256 encode-check< ;
