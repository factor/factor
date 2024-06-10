! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.styles kernel math namespaces regexp sequences
splitting strings strings.tables ;
IN: io.streams.escape-codes

<PRIVATE

CONSTANT: ansi-font-styles H{
    { bold "\e[1m" }
    { faint "\e[2m" }
    { italic "\e[3m" }
    { bold-italic "\e[1m\e[3m" }
    { underline "\e[4m" }
    { blink "\e[5m" }
}
PRIVATE>

: ansi-font-style ( font-style -- string )
    dup sequence? [
        [ ansi-font-styles at ] map concat
    ] [
        ansi-font-styles at
    ] if "" or ;

<PRIVATE

CONSTANT: ansi-escape-regexp R/ (\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]/

TUPLE: ansi-format ;

: ansi-escape-length ( str -- n )
    [ 0 ] dip ansi-escape-regexp [ drop swap - + ] each-match ;

M: ansi-format cell-length
    [ length ] [ ansi-escape-length ] bi - ;

PRIVATE>

: format-ansi-table ( table -- seq )
    T{ ansi-format } cell-format [ format-table ] with-variable ;

: format-ansi-table. ( table -- )
    T{ ansi-format } cell-format [ format-table. ] with-variable ;

: format-ansi-box ( table -- seq )
    T{ ansi-format } cell-format [ format-box ] with-variable ;

: format-ansi-box. ( table -- )
    T{ ansi-format } cell-format [ format-box. ] with-variable ;

: strip-ansi-escapes ( str -- str' )
    ansi-escape-regexp "" re-replace ;
