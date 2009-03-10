! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel io io.files combinators.short-circuit
math.order values assocs io.encodings io.binary fry strings math
io.encodings.ascii arrays byte-arrays accessors splitting
math.parser biassocs io.encodings.iana
locals multiline combinators simple-flat-file ;
IN: io.encodings.shift-jis

SINGLETON: shift-jis

shift-jis "Shift_JIS" register-encoding

SINGLETON: windows-31j

windows-31j "Windows-31J" register-encoding

<PRIVATE

VALUE: shift-jis-table

M: shift-jis <encoder> drop shift-jis-table <encoder> ;
M: shift-jis <decoder> drop shift-jis-table <decoder> ;

VALUE: windows-31j-table

M: windows-31j <encoder> drop windows-31j-table <encoder> ;
M: windows-31j <decoder> drop windows-31j-table <decoder> ;

TUPLE: jis assoc ;

: ch>jis ( ch tuple -- jis ) assoc>> value-at [ encode-error ] unless* ;
: jis>ch ( jis tuple -- string ) assoc>> at replacement-char or ;

: make-jis ( filename -- jis )
    flat-file>biassoc [ nip ] assoc-filter jis boa ;

"vocab:io/encodings/shift-jis/CP932.txt"
make-jis to: windows-31j-table

"vocab:io/encodings/shift-jis/sjis-0208-1997-std.txt"
make-jis to: shift-jis-table

: small? ( char -- ? )
    ! ASCII range or single-byte halfwidth katakana
    { [ 0 HEX: 7F between? ] [ HEX: A1 HEX: DF between? ] } 1|| ;

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
