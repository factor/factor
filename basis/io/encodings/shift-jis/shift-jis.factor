! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays
combinators.short-circuit endian io io.encodings
io.encodings.iana kernel math.bitwise math.order namespaces
simple-flat-file ;
IN: io.encodings.shift-jis

SINGLETON: shift-jis

shift-jis "Shift_JIS" register-encoding

SINGLETON: windows-31j

windows-31j "Windows-31J" register-encoding

<PRIVATE

SYMBOL: shift-jis-table

M: shift-jis <encoder> drop shift-jis-table get-global <encoder> ;
M: shift-jis <decoder> drop shift-jis-table get-global <decoder> ;

SYMBOL: windows-31j-table

M: windows-31j <encoder> drop windows-31j-table get-global <encoder> ;
M: windows-31j <decoder> drop windows-31j-table get-global <decoder> ;

TUPLE: jis assoc ;

: ch>jis ( ch tuple -- jis ) assoc>> value-at [ encode-error ] unless* ;
: jis>ch ( jis tuple -- string ) assoc>> at replacement-char or ;

: make-jis ( filename -- jis )
    load-codetable-file sift-values jis boa ;

"vocab:io/encodings/shift-jis/CP932.txt"
make-jis windows-31j-table set-global

"vocab:io/encodings/shift-jis/sjis-0208-1997-std.txt"
make-jis shift-jis-table set-global

: small? ( char -- ? )
    ! ASCII range or single-byte halfwidth katakana
    { [ 0 0x7F between? ] [ 0xA1 0xDF between? ] } 1|| ;

: write-halfword ( stream halfword -- )
    h>b/b swap 2byte-array swap stream-write ;

M: jis encode-char
    swapd ch>jis
    dup small?
    [ swap stream-write1 ]
    [ write-halfword ] if ;

M: jis decode-char
    swap dup stream-read1 [
        dup small? [ nip swap jis>ch ] [
            swap stream-read1
            [ 2array be> swap jis>ch ]
            [ 2drop replacement-char ] if*
        ] if
    ] [ 2drop f ] if* ;

PRIVATE>
