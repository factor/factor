! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings strings kernel math sequences byte-arrays io.encodings ;
IN: io.encodings.ascii

: encode-check<= ( string stream max -- )
    [ pick <= [ encode-error ] [ stream-write1 ] if ] 2curry each ;

TUPLE: ascii ;

M: ascii stream-write-encoded ( string stream encoding -- )
    drop 127 encode-check<= ;

M: ascii decode-step
    drop dup 128 >= [ decode-error ] [ swap push ] if ;
