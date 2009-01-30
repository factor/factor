! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser arrays io.encodings sequences kernel assocs
hashtables io.encodings.ascii generic parser classes.tuple words
words.symbol io io.files splitting namespaces math
compiler.units accessors ;
IN: io.encodings.8-bit

<PRIVATE

: mappings {
    { "latin1" "8859-1" }
    { "latin2" "8859-2" }
    { "latin3" "8859-3" }
    { "latin4" "8859-4" }
    { "latin/cyrillic" "8859-5" }
    { "latin/arabic" "8859-6" }
    { "latin/greek" "8859-7" }
    { "latin/hebrew" "8859-8" }
    { "latin5" "8859-9" }
    { "latin6" "8859-10" }
    { "latin/thai" "8859-11" }
    { "latin7" "8859-13" }
    { "latin8" "8859-14" }
    { "latin9" "8859-15" }
    { "latin10" "8859-16" }
    { "koi8-r" "KOI8-R" }
    { "windows-1252" "CP1252" }
    { "ebcdic" "CP037" }
    { "mac-roman" "ROMAN" }
} ;

: encoding-file ( file-name -- stream )
    "resource:basis/io/encodings/8-bit/" swap ".TXT"
    3append ascii <file-reader> ;

: process-contents ( lines -- assoc )
    [ "#" split1 drop ] map harvest
    [ "\t" split 2 head [ 2 short tail hex> ] map ] map ;

: byte>ch ( assoc -- array )
    256 replacement-char <array>
    [ [ swapd set-nth ] curry assoc-each ] keep ;

: ch>byte ( assoc -- newassoc )
    [ swap ] assoc-map >hashtable ;

: parse-file ( path -- byte>ch ch>byte )
    lines process-contents
    [ byte>ch ] [ ch>byte ] bi ;

SYMBOL: 8-bit-encodings

TUPLE: 8-bit decode encode ;

: encode-8-bit ( char stream assoc -- )
    swapd at*
    [ swap stream-write1 ] [ nip encode-error ] if ; inline

M: 8-bit encode-char encode>> encode-8-bit ;

: decode-8-bit ( stream array -- char/f )
    swap stream-read1 dup
    [ swap nth [ replacement-char ] unless* ] [ 2drop f ] if ; inline

M: 8-bit decode-char decode>> decode-8-bit ;

PREDICATE: 8-bit-encoding < word
    8-bit-encodings get-global key? ;

M: 8-bit-encoding <encoder>
    8-bit-encodings get-global at <encoder> ;

M: 8-bit-encoding <decoder>
    8-bit-encodings get-global at <decoder> ;

PRIVATE>

[
    mappings [
        [ "io.encodings.8-bit" create ]
        [ encoding-file parse-file 8-bit boa ]
        bi*
    ] assoc-map
    [ keys [ define-symbol ] each ]
    [ 8-bit-encodings set-global ]
    bi
] with-compilation-unit
