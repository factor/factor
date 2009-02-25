! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser arrays io.encodings sequences kernel assocs
hashtables io.encodings.ascii generic parser classes.tuple words
words.symbol io io.files splitting namespaces math
compiler.units accessors classes.singleton classes.mixin
io.encodings.iana fry ;
IN: io.encodings.8-bit

<PRIVATE

CONSTANT: mappings {
    ! encoding-name iana-name file-name
    { "latin1" "ISO_8859-1:1987" "8859-1" }
    { "latin2" "ISO_8859-2:1987" "8859-2" }
    { "latin3" "ISO_8859-3:1988" "8859-3" }
    { "latin4" "ISO_8859-4:1988" "8859-4" }
    { "latin/cyrillic" "ISO_8859-5:1988" "8859-5" }
    { "latin/arabic" "ISO_8859-6:1987" "8859-6" }
    { "latin/greek" "ISO_8859-7:1987" "8859-7" }
    { "latin/hebrew" "ISO_8859-8:1988" "8859-8" }
    { "latin5" "ISO_8859-9:1989" "8859-9" }
    { "latin6" "ISO-8859-10" "8859-10" }
    { "latin/thai" "TIS-620" "8859-11" }
    { "latin7" "ISO-8859-13" "8859-13" }
    { "latin8" "ISO-8859-14" "8859-14" }
    { "latin9" "ISO-8859-15" "8859-15" }
    { "latin10" "ISO-8859-16" "8859-16" }
    { "koi8-r" "KOI8-R" "KOI8-R" }
    { "windows-1252" "windows-1252" "CP1252" }
    { "ebcdic" "IBM037" "CP037" }
    { "mac-roman" "macintosh" "ROMAN" }
}

: encoding-file ( file-name -- stream )
    "vocab:io/encodings/8-bit/" ".TXT" surround ;

: process-contents ( lines -- assoc )
    [ "#" split1 drop ] map harvest
    [ "\t" split 2 head [ 2 short tail hex> ] map ] map ;

: byte>ch ( assoc -- array )
    256 replacement-char <array>
    [ '[ swap _ set-nth ] assoc-each ] keep ;

: ch>byte ( assoc -- newassoc )
    [ swap ] assoc-map >hashtable ;

: parse-file ( path -- byte>ch ch>byte )
    ascii file-lines process-contents
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

MIXIN: 8-bit-encoding

M: 8-bit-encoding <encoder>
    8-bit-encodings get-global at <encoder> ;

M: 8-bit-encoding <decoder>
    8-bit-encodings get-global at <decoder> ;

: create-encoding ( name -- word )
    "io.encodings.8-bit" create
    [ define-singleton-class ]
    [ 8-bit-encoding add-mixin-instance ]
    [ ] tri ;

PRIVATE>

[
    mappings [
        first3
        [ create-encoding ]
        [ dupd register-encoding ]
        [ encoding-file parse-file 8-bit boa ]
        tri*
    ] H{ } map>assoc
    8-bit-encodings set-global
] with-compilation-unit
