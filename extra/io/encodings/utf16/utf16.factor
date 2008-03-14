! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces io.binary
io.encodings combinators splitting io byte-arrays ;
IN: io.encodings.utf16

TUPLE: utf16be ;

TUPLE: utf16le ch state ;

TUPLE: utf16 started? ;

<PRIVATE

! UTF-16BE decoding

: append-nums ( byte ch -- ch )
    over [ 8 shift bitor ] [ 2drop replacement-char ] if ;

: double-be ( stream byte -- stream char )
    over stream-read1 swap append-nums ;

: quad-be ( stream byte -- stream char )
    double-be over stream-read1 dup [
        dup -2 shift BIN: 110111 number= [
            >r 2 shift r> BIN: 11 bitand bitor
            over stream-read1 swap append-nums HEX: 10000 +
        ] [ 2drop replacement-char ] if
    ] when ;

: ignore ( stream -- stream char )
    dup stream-read1 drop replacement-char ;

: begin-utf16be ( stream byte -- stream char )
    dup -3 shift BIN: 11011 number= [
        dup BIN: 00000100 bitand zero?
        [ BIN: 11 bitand quad-be ]
        [ drop ignore ] if
    ] [ double-be ] if ;
    
M: decode-char
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
    ] [ swap append-nums ] if ;

: decode-utf16le-step ( buf byte ch state -- buf ch state )
    {
        { begin [ drop double ] }
        { double [ handle-double ] }
        { quad2 [ 10 shift bitor quad3 ] }
        { quad3 [ handle-quad3le ] }
    } case ;

: begin-utf16le ( stream byte -- stream char )
    over stream-read1 [ double-le ] [ drop replacement-char ] if*

M: decode-char
    drop dup stream-read1 dup [ begin-utf16le ] when nip ;

! UTF-16LE/BE encoding

: encode-first
    -10 shift
    dup -8 shift BIN: 11011000 bitor
    swap HEX: FF bitand ;

: encode-second
    BIN: 1111111111 bitand
    dup -8 shift BIN: 11011100 bitor
    swap BIN: 11111111 bitand ;

: stream-write2 ( stream char1 char2 -- )
    rot [ stream-write1 ] 2apply ;

: char>utf16be ( stream char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup encode-first stream-write2
        encode-second stream-write2
    ] [ h>b/b swap stream-write2 ] if ;

M: utf16be encode-char ( char stream encoding -- )
    drop char>utf16be ;

: char>utf16le ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup encode-first swap stream-write2
        encode-second swap stream-write2
    ] [ h>b/b stream-write2 ] if ; 

: stream-write-utf16le ( string stream -- )
    [ [ char>utf16le ] each ] with-stream* ;

M: utf16le stream-write-encoded ( string stream encoding -- )
    drop stream-write-utf16le ;

! UTF-16

: bom-le B{ HEX: ff HEX: fe } ; inline

: bom-be B{ HEX: fe HEX: ff } ; inline

: start-utf16le? ( seq1 -- seq2 ? ) bom-le ?head ;

: start-utf16be? ( seq1 -- seq2 ? ) bom-be ?head ;

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf16le ] [
        bom-be sequence= [ utf16be ] [ decode-error ] if
    ] if ;

M: utf16 <decoder> ( stream utf16 -- decoder )
    2 rot stream-read bom>le/be <decoder> ;

M: utf16 <encoder> ( stream utf16 -- encoder )
    drop bom-le over stream-write utf16le <encoder> ;

PRIVATE>
