! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings kernel math ;
IN: io.encodings.ascii

<PRIVATE
: encode-if< ( char stream encoding max -- )
    nip pick > [ encode-error ] [ stream-write1 ] if ;

: decode-if< ( stream encoding max -- character )
    nip swap stream-read1 tuck > [ drop replacement-character ] unless ;
PRIVATE>

TUPLE: ascii ;

M: ascii encode-char
    128 encode-if< ;

M: ascii decode-char
    128 decode-if< ;
