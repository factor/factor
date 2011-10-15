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
    over stream-read1 dup [ double-le ] [ 2drop replacement-char ] if ;

M: utf16le decode-char
    drop dup stream-read1 dup [ begin-utf16le ] when nip ;

! UTF-16LE/BE encoding

: encode-first ( char -- byte1 byte2 )
    -10 shift
    [ -8 shift BIN: 11011000 bitor ] [ HEX: FF bitand ] bi ; inline

: encode-second ( char -- byte3 byte4 )
    BIN: 1111111111 bitand
    [ -8 shift BIN: 11011100 bitor ] [ BIN: 11111111 bitand ] bi ; inline

: stream-write2 ( char1 char2 stream -- )
    [ B{ } 2sequence ] dip stream-write ; inline
    ! [ stream-write1 ] curry bi@ ; inline

: char>utf16be ( char stream -- )
    over HEX: FFFF > [
        [ HEX: 10000 - ] dip
        [ [ encode-first ] dip stream-write2 ]
        [ [ encode-second ] dip stream-write2 ] 2bi
    ] [ [ h>b/b swap ] dip stream-write2 ] if ; inline

M: utf16be encode-char ( char stream encoding -- )
    drop char>utf16be ;

: char>utf16le ( char stream -- )
    over HEX: FFFF > [
        [ HEX: 10000 - ] dip
        [ [ encode-first swap ] dip stream-write2 ]
        [ [ encode-second swap ] dip stream-write2 ] 2bi
    ] [ [ h>b/b ] dip stream-write2 ] if ; inline

M: utf16le encode-char ( char stream encoding -- )
    drop char>utf16le ;

: ascii-char>utf16-byte-array ( off n byte-array string -- )
    [ over ] dip string-nth-fast -rot
    [ 2 fixnum*fast rot fixnum+fast ] dip
    set-nth-unsafe ; inline

: ascii-string>utf16-byte-array ( off string -- byte-array )
    [ length >fixnum [ iota ] [ 2 fixnum*fast <byte-array> ] bi ] keep
    [ [ ascii-char>utf16-byte-array ] 2curry with each ] 2keep drop ; inline

: ascii-string>utf16le ( string stream -- )
    [ 0 swap ascii-string>utf16-byte-array ] dip stream-write ; inline
: ascii-string>utf16be ( string stream -- )
    [ 1 swap ascii-string>utf16-byte-array ] dip stream-write ; inline

M: utf16le encode-string
    drop
    over aux>>
    [ [ char>utf16le ] curry each ]
    [ ascii-string>utf16le ] if ;

M: utf16be encode-string
    drop
    over aux>>
    [ [ char>utf16be ] curry each ]
    [ ascii-string>utf16be ] if ;

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
