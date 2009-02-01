! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io.encodings combinators io io.encodings.utf16
generalizations sequences ;
IN: io.encodings.utf32

SINGLETON: utf32be

SINGLETON: utf32le

SINGLETON: utf32

<PRIVATE

: 4spin ( a b c d -- b c d a )
    4 nrev ; inline

! Decoding

: stream-read4 ( stream -- a b c d )
    {
        [ stream-read1 ]
        [ stream-read1 ]
        [ stream-read1 ]
        [ stream-read1 ]
    } cleave ;

: with-replacement ( _ _ _ ch quot -- new-ch )
    [ 3drop replacement-char ] if* ; inline

: >char ( d c b a -- abcd )
    [
        24 shift -roll [
            16 shift -rot [
                8 shift swap [
                    bitor bitor bitor
                ] with-replacement
            ] with-replacement
        ] with-replacement
    ] with-replacement ;

M: utf32be decode-char
    drop stream-read4 4spin
    [ >char ] [ 3drop f ] if* ;

M: utf32le decode-char
    drop stream-read4 4 npick
    [ >char ] [ 2drop 2drop f ] if ;

! Encoding

: split-off ( ab -- b a )
    [ HEX: FF bitand ] [ -8 shift ] bi ;

: char> ( abcd -- d b c a )
    split-off split-off split-off ;

: stream-write4 ( d c b a stream -- )
    {
        [ stream-write1 ]
        [ stream-write1 ]
        [ stream-write1 ]
        [ stream-write1 ]
    } cleave ;

M: utf32be encode-char
    drop [ char> ] dip stream-write4 ;

M: utf32le encode-char
    drop [ char> 4spin ] dip stream-write4 ;

! UTF-32

: bom-le B{ HEX: ff HEX: fe 0 0 } ; inline

: bom-be B{ 0 0 HEX: fe HEX: ff } ; inline

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf32le ] [
        bom-be sequence= [ utf32be ] [ missing-bom ] if
    ] if ;

M: utf32 <decoder> ( stream utf32 -- decoder )
    drop 4 over stream-read bom>le/be <decoder> ;

M: utf32 <encoder> ( stream utf32 -- encoder )
    drop bom-le over stream-write utf32le <encoder> ;
