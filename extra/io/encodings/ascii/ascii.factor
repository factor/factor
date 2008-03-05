! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings strings kernel math sequences byte-arrays io.encodings ;
IN: io.encodings.ascii

: encode-check<= ( string max -- byte-array )
    dupd [ <= ] curry all? [ >byte-array ] [ encode-error ] if ;

TUPLE: ascii ;

M: ascii encode-string
    drop 127 encode-check<= ;

M: ascii decode-step
    drop dup 128 >= [ encode-error ] [ swap push ] if ;
