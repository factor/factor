! Copyright (C) 2006, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors byte-arrays io io.encodings
kernel math math.private sequences sequences.private strings
strings.private ;
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
        dup -2 shift 0b110111 number= [
            [ 2 shift ] dip 0b11 bitand bitor
            over stream-read1 swap append-nums 0x10000 +
        ] [ 2drop dup stream-read1 drop replacement-char ] if
    ] when* ;

: ignore ( stream -- stream char )
    dup stream-read1 drop replacement-char ;

: begin-utf16be ( stream byte -- stream char )
    dup -3 shift 0b11011 number= [
        dup 0b00000100 bitand zero?
        [ 0b11 bitand quad-be ]
        [ drop ignore ] if
    ] [ double-be ] if ;

M: utf16be decode-char
    drop dup stream-read1 dup [ begin-utf16be ] when nip ;

! UTF-16LE decoding

: quad-le ( stream ch -- stream char )
    over stream-read1 swap 10 shift bitor
    over stream-read1 dup -2 shift 0b110111 = [
        0b11 bitand append-nums 0x10000 +
    ] [ 2drop replacement-char ] if ;

: double-le ( stream byte1 byte2 -- stream char )
    dup -3 shift 0b11011 = [
        dup 0b100 bitand 0 number=
        [ 0b11 bitand 8 shift bitor quad-le ]
        [ 2drop replacement-char ] if
    ] [ append-nums ] if ;

: begin-utf16le ( stream byte -- stream char )
    over stream-read1 [ double-le ] [ drop replacement-char ] if* ;

M: utf16le decode-char
    drop dup stream-read1 dup [ begin-utf16le ] when nip ;

! UTF-16LE/BE encoding

: encode-first ( char -- byte1 byte2 )
    -10 shift
    [ -8 shift 0b11011000 bitor ] [ 0xFF bitand ] bi ; inline

: encode-second ( char -- byte3 byte4 )
    0b1111111111 bitand
    [ -8 shift 0b11011100 bitor ] [ 0b11111111 bitand ] bi ; inline

: stream-write2 ( char1 char2 stream -- )
    [ B{ } 2sequence ] dip stream-write ; inline
    ! [ stream-write1 ] curry bi@ ; inline

: split>b/b ( h -- b1 b2 ) ! duplicate from math.bitwise:h>b/b
    [ 0xff bitand ] [ -8 shift 0xff bitand ] bi ;

: char>utf16be ( char stream -- )
    over 0xFFFF > [
        [ 0x10000 - ] dip
        [ [ encode-first ] dip stream-write2 ]
        [ [ encode-second ] dip stream-write2 ] 2bi
    ] [ [ split>b/b swap ] dip stream-write2 ] if ; inline

M: utf16be encode-char
    drop char>utf16be ;

: char>utf16le ( char stream -- )
    over 0xFFFF > [
        [ 0x10000 - ] dip
        [ [ encode-first swap ] dip stream-write2 ]
        [ [ encode-second swap ] dip stream-write2 ] 2bi
    ] [ [ split>b/b ] dip stream-write2 ] if ; inline

M: utf16le encode-char
    drop char>utf16le ;

: ascii-char>utf16-byte-array ( off n byte-array string -- )
    overd string-nth-fast -rot
    [ 2 fixnum*fast rot fixnum+fast ] dip
    set-nth-unsafe ; inline

: ascii-string>utf16-byte-array ( off string -- byte-array )
    [ length >fixnum [ <iota> ] [ 2 fixnum*fast <byte-array> ] bi ] keep
    [ [ ascii-char>utf16-byte-array ] 2curry with each ] keepd ; inline

: ascii-string>utf16le ( string stream -- )
    [ 0 swap ascii-string>utf16-byte-array ] dip stream-write ; inline
: ascii-string>utf16be ( string stream -- )
    [ 1 swap ascii-string>utf16-byte-array ] dip stream-write ; inline

GENERIC#: encode-string-utf16le 1 ( string stream -- )

M: object encode-string-utf16le
    [ char>utf16le ] curry each ; inline

M: string encode-string-utf16le
    over aux>>
    [ call-next-method ]
    [ ascii-string>utf16le ] if ; inline

M: utf16le encode-string drop encode-string-utf16le ;

GENERIC#: encode-string-utf16be 1 ( string stream -- )

M: object encode-string-utf16be
    [ char>utf16be ] curry each ; inline

M: string encode-string-utf16be
    over aux>>
    [ call-next-method ]
    [ ascii-string>utf16be ] if ; inline

M: utf16be encode-string drop encode-string-utf16be ;

M: utf16le guess-encoded-length drop 2 * ; inline
M: utf16le guess-decoded-length drop 2 /i ; inline

M: utf16be guess-encoded-length drop 2 * ; inline
M: utf16be guess-decoded-length drop 2 /i ; inline

! UTF-16

CONSTANT: bom-le B{ 0xff 0xfe }

CONSTANT: bom-be B{ 0xfe 0xff }

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf16le ] [
        bom-be sequence= [ utf16be ] [ missing-bom ] if
    ] if ;

M: utf16 <decoder>
    drop 2 over stream-read bom>le/be <decoder> ;

M: utf16 <encoder>
    drop bom-le over stream-write utf16le <encoder> ;

PRIVATE>

SINGLETON: utf16n

: choose-utf16-endian ( -- descriptor )
    B{ 1 0 0 0 } 0 alien-unsigned-4 1 = utf16le utf16be ? ; foldable

M: utf16n <decoder> drop choose-utf16-endian <decoder> ;

M: utf16n <encoder> drop choose-utf16-endian <encoder> ;
