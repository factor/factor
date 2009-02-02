! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel io io.files combinators.short-circuit
math.order values assocs io.encodings io.binary fry strings
math io.encodings.utf8 arrays accessors splitting math.parser ;
IN: io.encodings.japanese

! The code page used is Microsoft Code Page 932, 
! which is a set of extensions to JIS X 0208:1997

VALUE: shift-jis

VALUE: windows-31j

<PRIVATE

TUPLE: jis jis>ch ch>jis ;

: <jis> ( assoc -- jis )
    [ nip ] assoc-filter
    [ H{ } assoc-like ]
    [ [ swap ] H{ } assoc-map-as ] bi
    jis boa ;

: ch>jis ( ch tuple -- jis ) ch>jis>> at [ encode-error ] unless* ;
: jis>ch ( jis tuple -- string ) jis>ch>> at replacement-char or ;

: process-jis ( lines -- assoc )
    [ "#" split1 drop ] map harvest [
        "\t" split 2 head
        [ 2 short tail hex> ] map
    ] map ;

: make-jis ( filename -- jis )
    utf8 file-lines process-jis <jis> ;

"resource:basis/io/encodings/japanese/CP932.txt"
make-jis to: windows-31j

"resource:basis/io/encodings/japanese/sjis-0208-1997-std.txt"
make-jis to: shift-jis

: small? ( char -- ? )
    ! ASCII range or single-byte halfwidth katakana
    { [ 0 HEX: 7F between? ] [ HEX: A1 HEX: DF between? ] } 1|| ;

: write-halfword ( stream halfword -- )
    h>b/b swap 2array >string swap stream-write ;

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
