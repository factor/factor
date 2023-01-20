! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io io.encodings io.encodings.private kernel
math sequences strings ;
IN: io.encodings.ascii

SINGLETON: ascii

M: ascii encode-char
    drop
    over 127 <= [ stream-write1 ] [ encode-error ] if ; inline

<PRIVATE

GENERIC: ascii> ( string -- byte-array )

M: object ascii>
    [ dup 127 <= [ encode-error ] unless ] B{ } map-as ; inline

M: string ascii>
    dup aux>>
    [ call-next-method ]
    [ string>byte-array-fast ] if ; inline

PRIVATE>

M: ascii encode-string
    drop
    [ ascii> ] dip stream-write ;

M: ascii decode-char
    drop
    stream-read1 dup [
        dup 127 <= [ >fixnum ] [ drop replacement-char ] if
    ] when ; inline

M: ascii decode-until (decode-until) ;
