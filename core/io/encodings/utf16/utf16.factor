! Copyright (C) 2006, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces io.binary
io.encodings combinators splitting io byte-arrays ;
IN: io.encodings.utf16

SINGLETON: utf16be

SINGLETON: utf16le

SINGLETON: utf16

ERROR: missing-bom ;

<PRIVATE

! UTF-16BE decoding

: append-nums ( byte ch -- ch )
    over [ 8 shift bitor ] [ 2drop replacement-char ] if ;

: double-be ( stream byte -- stream char )
    over stream-read1 swap append-nums ;

: quad-be ( stream byte -- stream char )
    double-be over stream-read1 [
        dup -2 shift BIN: 110111 number= [
            [ 2 shift ] dip BIN: 11 bitand bitor
            over stream-read1 swap append-nums HEX: 10000 +
        ] [ 2drop dup stream-read1 drop replacement-char ] if
    ] when* ;

: ignore ( stream -- stream char )
    dup stream-read1 drop replacement-char ;

: begin-utf16be ( stream byte -- stream char )
    dup -3 shift BIN: 11011 number= [
        dup BIN: 00000100 bitand zero?
        [ BIN: 11 bitand quad-be ]
        [ drop ignore ] if
    ] [ double-be ] if ;
    
M: utf16be decode-char
    drop dup stream-read1 dup [ begin-utf16be ] when nip ;

! UTF-16LE decoding

: quad-le ( stream ch -- stream char )
    over stream-read1 swap 10 shift bitor
    over stream-read1 dup -2 shift BIN: 110111 = [
        BIN: 11 bitand append-nums HEX: 10000 +
    ] [ 2drop replacement-char ] if ;

: double-le ( stream byte1 byte2 -- stream char )
    dup -3 shift BIN: 11011 = [
        dup BIN: 100 bitand 0 number=
        [ BIN: 11 bitand 8 shift bitor quad-le ]
        [ 2drop replacement-char ] if
    ] [ append-nums ] if ;

: begin-utf16le ( stream byte -- stream char )
    over stream-read1 [ double-le ] [ drop replacement-char ] if* ;

M: utf16le decode-char
    drop dup stream-read1 dup [ begin-utf16le ] when nip ;

! UTF-16LE/BE encoding

: encode-first ( char -- byte1 byte2 )
    -10 shift
    dup -8 shift BIN: 11011000 bitor
    swap HEX: FF bitand ;

: encode-second ( char -- byte3 byte4 )
    BIN: 1111111111 bitand
    dup -8 shift BIN: 11011100 bitor
    swap BIN: 11111111 bitand ;

: stream-write2 ( stream char1 char2 -- )
    rot [ stream-write1 ] curry bi@ ;

: char>utf16be ( stream char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        2dup encode-first stream-write2
        encode-second stream-write2
    ] [ h>b/b swap stream-write2 ] if ;

M: utf16be encode-char ( char stream encoding -- )
    drop swap char>utf16be ;

: char>utf16le ( char stream -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        2dup encode-first swap stream-write2
        encode-second swap stream-write2
    ] [ h>b/b stream-write2 ] if ; 

M: utf16le encode-char ( char stream encoding -- )
    drop swap char>utf16le ;

! UTF-16

CONSTANT: bom-le B{ HEX: ff HEX: fe }

CONSTANT: bom-be B{ HEX: fe HEX: ff }

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf16le ] [
        bom-be sequence= [ utf16be ] [ missing-bom ] if
    ] if ;

M: utf16 <decoder> ( stream utf16 -- decoder )
    drop 2 over stream-read bom>le/be <decoder> ;

M: utf16 <encoder> ( stream utf16 -- encoder )
    drop bom-le over stream-write utf16le <encoder> ;

PRIVATE>
