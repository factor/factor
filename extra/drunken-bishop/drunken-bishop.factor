! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: byte-arrays combinators endian io kernel math
math.bitwise math.order math.parser namespaces sequences strings
;

IN: drunken-bishop

<PRIVATE

CONSTANT: SYMBOLS " .o+=*BOX@%&#/^SE"

SYMBOL: board-width
board-width [ 17 ] initialize

SYMBOL: board-height
board-height [ 9 ] initialize

:: drunken-bishop ( bytes -- board )
    board-width get :> w
    board-height get :> h
    h [ w <byte-array> ] replicate :> board
    h 2/ :> y!
    w 2/ :> x!

    15 x y board nth set-nth

    bytes [
        { 0 -2 -4 -6 } [
            shift 2 bits {
                { 0b00 [ -1 -1 ] }
                { 0b01 [ -1  1 ] }
                { 0b10 [  1 -1 ] }
                { 0b11 [  1  1 ] }
            } case :> ( dy dx )
            dy y + 0 h 1 - clamp y!
            dx x + 0 w 1 - clamp x!
            x y board nth [ 1 + 14 min ] change-nth
        ] with each
    ] each

    16 x y board nth set-nth

    board ;

PRIVATE>

GENERIC: drunken-bishop. ( n -- )

M: string drunken-bishop.
    hex-string>bytes drunken-bishop. ;

M: integer drunken-bishop.
    dup log2 8 /mod zero? [ 1 + ] unless >be drunken-bishop. ;

M: byte-array drunken-bishop.
    board-width get CHAR: - <string> "+" "+" surround [
        print
        drunken-bishop [
            SYMBOLS nths "|" "|" surround print
        ] each
    ] [ print ] bi ;
