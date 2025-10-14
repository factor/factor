! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators endian io io.encodings io.encodings.iana
io.encodings.utf16 kernel sequences ;
IN: io.encodings.utf32

SINGLETON: utf32be

utf32be "UTF-32BE" register-encoding

SINGLETON: utf32le

utf32le "UTF-32LE" register-encoding

SINGLETON: utf32

utf32 "UTF-32" register-encoding

<PRIVATE

! Decoding

: char> ( stream quot -- ch )
    swap [ 4 ] dip stream-read dup length {
        { 0 [ 2drop f ] }
        { 4 [ swap call ] }
        [ 3drop replacement-char ]
    } case ; inline

M: utf32be decode-char drop [ be> ] char> ;

M: utf32le decode-char drop [ le> ] char> ;

! Encoding

: >char ( char stream quot -- )
    4 swap curry dip stream-write ; inline

M: utf32be encode-char drop [ >be ] >char ;

M: utf32le encode-char drop [ >le ] >char ;

! UTF-32

CONSTANT: bom-le B{ 0xff 0xfe 0 0 }

CONSTANT: bom-be B{ 0 0 0xfe 0xff }

:: ?skip-bom ( stream bom -- )
    stream stream-seekable? [
        stream stream-tell
        4 stream stream-read-partial bom sequence=
        [ drop ] [ seek-absolute stream stream-seek ] if
    ] when ; inline

M: utf32le <decoder> over bom-le ?skip-bom call-next-method ;

M: utf32be <decoder> over bom-be ?skip-bom call-next-method ;

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [
        drop utf32le
    ] [
        bom-be sequence= [ utf32be ] [ missing-bom ] if
    ] if ;

M: utf32 <decoder>
    drop 4 over stream-read bom>le/be <decoder> ;

M: utf32 <encoder>
    drop bom-le over stream-write utf32le <encoder> ;

PRIVATE>
