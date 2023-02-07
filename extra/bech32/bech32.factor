! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii base64.private byte-arrays
combinators.short-circuit kernel literals math math.order
sequences ;

IN: bech32

<PRIVATE

<<
CONSTANT: alphabet $[ "qpzry9x8gf2tvdw0s3jn54khce6mua7l" >byte-array ]
>>

: bech32-polymod ( values -- n )
    1 [
        over
        [ 0x1ffffff bitand 5 shift ] [ bitxor ] [ -25 shift ] tri*
        { 0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3 } [
            bit? [ bitxor ] [ drop ] if
        ] with each-index
    ] reduce ;

: bech32-hrp-expand ( s -- t )
    [ [ -5 shift ] map B{ 0 } ] [ [ 0x1f bitand ] map 3append ] bi ;

: bech32-hrp-data ( hrp data -- seq )
    [ bech32-hrp-expand ] [ append ] bi* ;

: bech32-checksum? ( hrp data checksum -- ? )
    [ bech32-hrp-data bech32-polymod ] [ = ] bi* ;

: bech32-checksum ( hrp data checksum -- checksum )
    [ bech32-hrp-data B{ 0 0 0 0 0 0 } append bech32-polymod ]
    [ bitxor ] bi* 6 [
       5 - 5 * shift 0x1f bitand
    ] with B{ } map-integers-as ;

: bech32-encode ( hrp data checksum -- bech32 )
    [ dup ] 2dip over [ bech32-checksum ] [ prepend ] bi*
    [ alphabet nth ] map "1" glue ;

: bech32-decode ( bech32 checksum -- hrp data )
    over {
        [ [ 33 126 between? not ] any? ]
        [ [ dup >lower = ] [ dup >upper = ] bi or not ]
    } 1|| [ 2drop f f ] [
        swap >lower CHAR: 1 over last-index {
            [ dup not ]
            [ dup 1 83 between? not ]
            [ 2dup [ length ] [ 7 + ] bi* < ]
        } 0|| [ 3drop f f ] [
            cut rest [ $[ alphabet alphabet-inverse ] nth 0xff or ] B{ } map-as
            dup [ 0xff = ] any? [ 3drop f f ] [
                rot [ 2dup ] dip bech32-checksum?
                [ 6 head* ] [ 2drop f f ] if
            ] if
        ] if
    ] if ;

PRIVATE>

: >bech32 ( hrp data -- bech32 )
    1 bech32-encode ;

: bech32> ( bech32 -- hrp data )
    1 bech32-decode ;

: >bech32m ( hrp data -- bech32m )
    0x2bc830a3 bech32-encode ;

: bech32m> ( bech32 -- hrp data )
    0x2bc830a3 bech32-decode ;
