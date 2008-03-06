! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces io.binary
io.encodings combinators splitting io byte-arrays ;
IN: io.encodings.utf16

! UTF-16BE decoding

TUPLE: utf16be ch state ;

SYMBOL: double
SYMBOL: quad1
SYMBOL: quad2
SYMBOL: quad3
SYMBOL: ignore

: do-ignore ( -- ch state ) 0 ignore ;

: append-nums ( byte ch -- ch )
    8 shift bitor ;

: end-multibyte ( buf byte ch -- buf ch state )
    append-nums push-decoded ;

: begin-utf16be ( buf byte -- buf ch state )
    dup -3 shift BIN: 11011 number= [
        dup BIN: 00000100 bitand zero?
        [ BIN: 11 bitand quad1 ]
        [ drop do-ignore ] if
    ] [ double ] if ;

: handle-quad2be ( byte ch -- ch state )
    swap dup -2 shift BIN: 110111 number= [
        >r 2 shift r> BIN: 11 bitand bitor quad3
    ] [ 2drop do-ignore ] if ;

: decode-utf16be-step ( buf byte ch state -- buf ch state )
    {
        { begin [ drop begin-utf16be ] }
        { double [ end-multibyte ] }
        { quad1 [ append-nums quad2 ] }
        { quad2 [ handle-quad2be ] }
        { quad3 [ append-nums HEX: 10000 + push-decoded ] }
        { ignore [ 2drop push-replacement ] }
    } case ;

: unpack-state-be ( encoding -- ch state )
    { utf16be-ch utf16be-state } get-slots ;

: pack-state-be ( ch state encoding -- )
    { set-utf16be-ch set-utf16be-state } set-slots ;

M: utf16be decode-step
    [ unpack-state-be decode-utf16be-step ] keep pack-state-be drop ;

M: utf16be init-decoder nip begin over set-utf16be-state ;

! UTF-16LE decoding

TUPLE: utf16le ch state ;

: handle-double ( buf byte ch -- buf ch state )
    swap dup -3 shift BIN: 11011 = [
        dup BIN: 100 bitand 0 number=
        [ BIN: 11 bitand 8 shift bitor quad2 ]
        [ 2drop push-replacement ] if
    ] [ end-multibyte ] if ;

: handle-quad3le ( buf byte ch -- buf ch state )
    swap dup -2 shift BIN: 110111 = [
        BIN: 11 bitand append-nums HEX: 10000 + push-decoded
    ] [ 2drop push-replacement ] if ;

: decode-utf16le-step ( buf byte ch state -- buf ch state )
    {
        { begin [ drop double ] }
        { double [ handle-double ] }
        { quad1 [ append-nums quad2 ] }
        { quad2 [ 10 shift bitor quad3 ] }
        { quad3 [ handle-quad3le ] }
    } case ;

: unpack-state-le ( encoding -- ch state )
    { utf16le-ch utf16le-state } get-slots ;

: pack-state-le ( ch state encoding -- )
    { set-utf16le-ch set-utf16le-state } set-slots ;

M: utf16le decode-step
    [ unpack-state-le decode-utf16le-step ] keep pack-state-le drop ;

M: utf16le init-decoder nip begin over set-utf16le-state ;

! UTF-16LE/BE encoding

: encode-first
    -10 shift
    dup -8 shift BIN: 11011000 bitor
    swap HEX: FF bitand ;

: encode-second
    BIN: 1111111111 bitand
    dup -8 shift BIN: 11011100 bitor
    swap BIN: 11111111 bitand ;

: char>utf16be ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup encode-first swap write1 write1
        encode-second swap write1 write1
    ] [ h>b/b write1 write1 ] if ;

: stream-write-utf16be ( string stream -- )
    [ [ char>utf16be ] each ] with-stream* ;

M: utf16be stream-write-encoded ( string stream encoding -- )
    drop stream-write-utf16be ;

: char>utf16le ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup encode-first write1 write1
        encode-second write1 write1
    ] [ h>b/b swap write1 write1 ] if ; 

: stream-write-utf16le ( string stream -- )
    [ [ char>utf16le ] each ] with-stream* ;

M: utf16le stream-write-encoded ( string stream encoding -- )
    drop stream-write-utf16le ;

! UTF-16

: bom-le B{ HEX: ff HEX: fe } ; inline

: bom-be B{ HEX: fe HEX: ff } ; inline

: start-utf16le? ( seq1 -- seq2 ? ) bom-le ?head ;

: start-utf16be? ( seq1 -- seq2 ? ) bom-be ?head ;

TUPLE: utf16 started? ;

M: utf16 stream-write-encoded
    dup utf16-started? [ drop ]
    [ t swap set-utf16-started? bom-le over stream-write ] if
    stream-write-utf16le ;

: bom>le/be ( bom -- le/be )
    dup bom-le sequence= [ drop utf16le ] [
        bom-be sequence= [ utf16be ] [ decode-error ] if
    ] if ;

M: utf16 init-decoder ( stream encoding -- newencoding )
    2 rot stream-read bom>le/be construct-empty init-decoder ;
