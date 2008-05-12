! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings kernel math io.encodings.private ;
IN: io.encodings.ascii

<PRIVATE
: encode-if< ( char stream encoding max -- )
    nip 1- pick < [ encode-error ] [ stream-write1 ] if ;

: decode-if< ( stream encoding max -- character )
    nip swap stream-read1
    [ tuck > [ drop replacement-char ] unless ]
    [ drop f ] if* ;
PRIVATE>

SINGLETON: ascii

M: ascii encode-char
    128 encode-if< ;

M: ascii decode-char
    128 decode-if< ;
