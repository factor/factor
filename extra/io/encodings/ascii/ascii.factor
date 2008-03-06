! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings strings kernel math sequences byte-arrays io.encodings ;
IN: io.encodings.ascii

: encode-check< ( string stream max -- )
    [ pick <= [ encode-error ] [ stream-write1 ] if ] 2curry each ;

: push-if< ( sbuf character max -- )
    over <= [ drop HEX: fffd ] when swap push ;

TUPLE: ascii ;

M: ascii stream-write-encoded ( string stream encoding -- )
    drop 128 encode-check< ;

M: ascii decode-step
    drop 128 push-if< ;
