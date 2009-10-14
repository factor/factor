! (c)Joe Groff bsd license
USING: alien alien.c-types alien.data alien.parser arrays
byte-arrays fry generalizations kernel lexer locals macros math
math.ranges parser sequences sequences.private ;
IN: alien.data.map

ERROR: bad-data-map-input-length byte-length iter-size remainder ;

<PRIVATE

: even-/i ( d d -- q )
    2dup [ >fixnum ] bi@ /mod
    [ 2nip ]
    [ bad-data-map-input-length ] if-zero ; inline

:: data-map-length ( array type count -- byte-length iter-size iter-count )
    array byte-length >fixnum
    type heap-size count *
    2dup even-/i ; inline

: <displaced-direct-array> ( byte-array displacement length type -- direct-array )
    [ swap <displaced-alien> ] 2dip <c-direct-array> ; inline

:: data-map-loop ( input loop-quot out-bytes-quot in-type in-count out-type out-count -- out-bytes )
    input in-type in-count data-map-length
        :> iter-count :> in-size :> in-byte-length
    input >c-ptr :> in-bytes

    out-count out-type heap-size * :> out-size
    out-size iter-count * :> out-byte-length
    out-byte-length out-bytes-quot call :> out-bytes

    0 in-byte-length 1 - >fixnum in-size >fixnum <range>
    0 out-byte-length 1 - >fixnum out-size >fixnum <range>
    [| in-base out-base |
        in-bytes in-base in-count in-type <displaced-direct-array>
        in-count firstn-unsafe
        loop-quot call
        out-bytes out-base out-count out-type <displaced-direct-array>
        out-count set-firstn-unsafe
    ] 2each
    out-bytes ; inline

PRIVATE>

MACRO: data-map ( in-type in-count out-type out-count -- )
    '[ [ (byte-array) ] _ _ _ _ data-map-loop ] ;

MACRO: data-map! ( in-type in-count out-type out-count -- )
    '[ swap [ [ nip >c-ptr ] curry _ _ _ _ data-map-loop drop ] keep ] ;

<PRIVATE

: c-type-parsed ( accum c-type -- accum )
    dup array? [ unclip swap product ] [ 1 ] if
    [ parsed ] bi@ ;

PRIVATE>

SYNTAX: data-map(
    scan-c-type c-type-parsed
    "--" expect scan-c-type c-type-parsed ")" expect
    \ data-map parsed ;

SYNTAX: data-map!(
    scan-c-type c-type-parsed
    "--" expect scan-c-type c-type-parsed ")" expect
    \ data-map! parsed ;

