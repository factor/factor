! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io.encodings combinators io io.encodings.utf16
sequences io.binary io.encodings.iana ;
IN: io.encodings.utf32

SINGLETON: utf32be

utf32be "UTF-32BE" register-encoding

SINGLETON: utf32le

utf32le "UTF-32LE" register-encoding

SINGLETON: utf32

utf32 "UTF-32" register-encoding

<PRIVATE

! Decoding

: char> ( stream encoding quot -- ch )
    nip swap 4 swap stream-read dup length {
        { 0 [ 2drop f ] }
        { 4 [ swap call ] }
        [ 3drop replacement-char ]
    } case ; inline

M: utf32be decode-char
    [ be> ] char> ;

M: utf32le decode-char
    [ le> ] char> ;

! Encoding

: >char ( char stream encoding quot -- )
    nip 4 swap curry dip stream-write ; inline

M: utf32be encode-char
    [ >be ] >char ;

M: utf32le encode-char
    [ >le ] >char ;

! UTF-32

CONSTANT: bom-le B{ HEX: ff HEX: fe 0 0 }

CONSTANT: bom-be B{ 0 0 HEX: fe HEX: ff }

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf32le ] [
        bom-be sequence= [ utf32be ] [ missing-bom ] if
    ] if ;

M: utf32 <decoder> ( stream utf32 -- decoder )
    drop 4 over stream-read bom>le/be <decoder> ;

M: utf32 <encoder> ( stream utf32 -- encoder )
    drop bom-le over stream-write utf32le <encoder> ;
