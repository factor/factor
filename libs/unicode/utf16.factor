USING: kernel sequences namespaces math utf8 ;
IN: utf16

! * UTF-16BE decoding

! I'm using the same states as utf8 but they have
! slightly different meanings
TUPLE: recover ; ! recovering from an error

GENERIC: (utf16be) ( char state -- state )
M: new (utf16be)
    drop dup -3 shift BIN: 11011 = [
        dup BIN: 00000100 bitand 0 =
        [ BIN: 11 bitand <quad1> ]
        [ drop bad-char , <recover> ] if
    ] [ <double> ] if ;
M: recover (utf16be)
    2drop <new> ;
M: double (utf16be)
    double-val 8 shift bitor , <new> ;
M: quad1 (utf16be)
    quad1-val 8 shift bitor <quad2> ;
M: quad2 (utf16be)
    over -2 shift BIN: 110111 = [
        quad2-val 2 shift swap
        BIN: 11 bitand bitor <quad3>
    ] [ 2drop bad-char , <recover> ] if ;
M: quad3 (utf16be)
    quad3-val 8 shift bitor HEX: 10000 + , <new> ;

: utf16be ( state string -- state string )
    [ [ swap (utf16be) ] each ] { } make ;

! * UTF-16BE encoding

: char>utf16be ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup -10 shift dup -8 shift BIN: 11011000 bitor ,
        HEX: FF bitand ,
        BIN: 1111111111 bitand
        dup -8 shift BIN: 11011100 bitor ,
        BIN: 11111111 bitand ,
    ]
    [ dup -8 shift , HEX: FF bitand , ] if ;

: string>utf16be ( string -- utf16be )
    [ [ char>utf16be ] each ] { } make ;


! * UTF-16LE decoding

GENERIC: (utf16le) ( char state -- state )
M: new (utf16le)
    drop <double> ;
M: double (utf16le)
    over -3 shift BIN: 11011 = [
        over BIN: 100 bitand 0 =
        [ double-val swap BIN: 11 bitand 8 shift bitor <quad2> ]
        [ 2drop bad-char , <new> ] if
    ] [ double-val swap 8 shift bitor , <new> ] if ;
M: quad2 (utf16le)
    quad2-val 10 shift bitor <quad3> ;
M: quad3 (utf16le)
    over -2 shift BIN: 110111 = [
        swap BIN: 11 bitand 8 shift
        swap quad3-val bitor HEX: 10000 + , <new>
    ] [ 2drop bad-char , <new> ] if ;

: utf16le ( state string -- state string )
    [ [ swap (utf16le) ] each ] { } make ;

! * UTF-16LE encoding

: char>utf16le ( char -- )
    dup HEX: FFFF > [
        HEX: 10000 -
        dup -10 shift
        dup HEX: FF bitand ,
        -8 shift BIN: 11011000 bitor ,
        dup BIN: 11111111 bitand ,
        -8 shift BIN: 11 bitand BIN: 11011100 bitor ,
    ]
    [ dup HEX: FF bitand , -8 shift , ] if ; 

: string>utf16le ( string -- utf16le )
    [ [ char>utf16le ] each ] { } make ;
