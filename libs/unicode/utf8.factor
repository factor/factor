USING: sequences kernel math namespaces ;
IN: utf8

! * UTF-8 decoding

! states
TUPLE: new ; ! waiting for beginning of new character
TUPLE: double val ;
TUPLE: triple1 val ;
TUPLE: triple2 val ;
TUPLE: quad1 val ;
TUPLE: quad2 val ;
TUPLE: quad3 val ;

: starts-2? ( char -- ? )
    -6 shift BIN: 10 = ;

: bad-char ( -- char ) CHAR: ? ;

: assure-utf8 ( char state quot -- state ) ! quot: char state -- state
    pick starts-2? swap
    [ 2drop bad-char , <new> ] if ; inline

: append-nums ( bottom top -- num )
    6 shift swap BIN: 111111 bitand bitor ;

GENERIC: (utf8) ( char state -- state )
M: new (utf8)
    drop {
        { [ dup -7 shift 0 = ] [ , <new> ] }
        { [ dup -5 shift BIN: 110 = ]
          [ BIN: 11111 bitand <double> ] }
        { [ dup -4 shift BIN: 1110 = ]
          [ BIN: 1111 bitand <triple1> ] }
        { [ dup -3 shift BIN: 11110 = ]
          [ BIN: 111 bitand <quad1> ] }
        { [ t ] [ drop bad-char , <new> ] }
    } cond ;
M: double (utf8)
    [ double-val append-nums , <new> ] assure-utf8 ;
M: triple1 (utf8)
    [ triple1-val append-nums <triple2> ] assure-utf8 ;
M: triple2 (utf8)
    [ triple2-val append-nums , <new> ] assure-utf8 ;
M: quad1 (utf8)
    [ quad1-val append-nums <quad2> ] assure-utf8 ;
M: quad2 (utf8)
    [ quad2-val append-nums <quad3> ] assure-utf8 ;
M: quad3 (utf8)
    [ quad3-val append-nums , <new> ] assure-utf8 ;

: utf8 ( state string -- state string )
    [ [ swap (utf8) ] each ] { } make ;

! * UTF-8 encoding

: mask ( char -- char )
    BIN: 111111 bitand BIN: 10000000 bitor ;

: char>utf8 ( char -- )
    {
        { [ dup -7 shift 0 = ] [ , ] }
        { [ dup -11 shift 0 = ] [
            dup -6 shift BIN: 11000000 bitor ,
            mask ,
        ] }
        { [ dup -16 shift 0 = ] [
            dup -12 shift BIN: 11100000 bitor ,
            dup -6 shift mask ,
            mask ,
        ] }
        { [ t ] [
            dup -18 shift BIN: 11110000 bitor ,
            dup -12 shift mask ,
            dup -6 shift mask ,
            mask ,
        ] }
    } cond ;

: string>utf8 ( string -- utf8 )
    [ [ char>utf8 ] each ] { } make ;
