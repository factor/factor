! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io io.encodings
io.encodings.private kernel math sequences ;
IN: io.encodings.ascii

SINGLETON: ascii

M: ascii encode-char
    drop
    over 127 <= [ stream-write1 ] [ encode-error ] if ; inline

M: ascii encode-string
    drop
    [
        dup aux>>
        [ [ dup 127 <= [ encode-error ] unless ] B{ } map-as ]
        [ >byte-array ]
        if
    ] dip
    stream-write ;

M: ascii decode-char
    drop
    stream-read1 dup [
        dup 127 <= [ >fixnum ] [ drop replacement-char ] if
    ] when ; inline

M: ascii decode-until (decode-until) ;
