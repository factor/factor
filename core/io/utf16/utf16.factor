! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors namespaces io.binary
io.encodings combinators splitting ;
IN: io.utf16

SYMBOL: double
SYMBOL: quad1
SYMBOL: quad2
SYMBOL: quad3

: append-nums ( byte ch -- ch )
    8 shift bitor ;

: end-multibyte ( buf byte ch -- buf ch state )
    append-nums decoded ;

: begin-utf16be ( buf byte -- buf ch state )
    dup -3 shift BIN: 11011 number= [
        dup BIN: 00000100 bitand zero?
        [ BIN: 11 bitand quad1 ]
        [ decode-error ] if
    ] [ double ] if ;

: handle-quad2be ( byte ch -- ch )
    swap dup -2 shift BIN: 110111 number= [
        >r 2 shift r> BIN: 11 bitand bitor
    ] [ decode-error ] if ;

: (decode-utf16be) ( buf byte ch state -- buf ch state )
    {
        { begin [ drop begin-utf16be ] }
        { double [ end-multibyte ] }
        { quad1 [ append-nums quad2 ] }
        { quad2 [ handle-quad2be quad3 ] }
        { quad3 [ append-nums HEX: 10000 + decoded ] }
    } case ;

: decode-utf16be ( seq -- str )
    [ -rot (decode-utf16be) ] decode ;

: handle-double ( buf byte ch -- buf ch state )
    swap dup -3 shift BIN: 11011 = [
        dup BIN: 100 bitand 0 number=
        [ BIN: 11 bitand 8 shift bitor quad2 ]
        [ decode-error ] if
    ] [ end-multibyte ] if ;

: handle-quad3le ( buf byte ch -- buf ch state )
    swap dup -2 shift BIN: 110111 = [
        BIN: 11 bitand append-nums HEX: 10000 + decoded
    ] [ decode-error ] if ;

: (decode-utf16le) ( buf byte ch state -- buf ch state )
    {
        { begin [ drop double ] }
        { double [ handle-double ] }
        { quad1 [ append-nums quad2 ] }
        { quad2 [ 10 shift bitor quad3 ] }
        { quad3 [ handle-quad3le ] }
    } case ;

: decode-utf16le ( seq -- str )
    [ -rot (decode-utf16le) ] decode ;

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
        dup encode-first swap , ,
        encode-second swap , ,
    ] [ h>b/b , , ] if ;

: encode-utf16be ( str -- seq )
    [ [ char>utf16be ] each ] B{ } make ;

: char>utf16le ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup encode-first , ,
        encode-second , ,
    ] [ h>b/b swap , , ] if ; 

: encode-utf16le ( str -- seq )
    [ [ char>utf16le ] each ] B{ } make ;

: bom-le B{ HEX: ff HEX: fe } ; inline

: bom-be B{ HEX: fe HEX: ff } ; inline

: encode-utf16 ( str -- seq )
    encode-utf16le bom-le swap append ;

: utf16le? ( seq1 -- seq2 ? ) bom-le ?head ;

: utf16be? ( seq1 -- seq2 ? ) bom-be ?head ;

: decode-utf16 ( seq -- str )
    {
        { [ utf16le? ] [ decode-utf16le ] }
        { [ utf16be? ] [ decode-utf16be ] }
        { [ t ] [ decode-error ] }
    } cond ;

