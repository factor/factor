! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser arrays io.encodings sequences kernel
assocs hashtables io.encodings.ascii combinators.cleave
generic parser tuples words io io.files splitting namespaces
math compiler.units accessors ;
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

: full-path ( file-name -- path )
    "extra/io/encodings/8-bit/" ".TXT"
    swapd 3append resource-path ;

: tail-if ( seq n -- newseq )
    2dup swap length <= [ tail ] [ drop ] if ;

: process-contents ( lines -- assoc )
    [ "#" split1 drop ] map
    [ empty? not ] subset
    [ "\t" split 2 head [ 2 tail-if hex> ] map ] map ;

: byte>ch ( assoc -- array )
    256 replacement-char <array>
    [ [ swapd set-nth ] curry assoc-each ] keep ;

: ch>byte ( assoc -- newassoc )
    [ swap ] assoc-map >hashtable ;

: parse-file ( file-name -- byte>ch ch>byte )
    ascii file-lines process-contents
    [ byte>ch ] [ ch>byte ] bi ;

TUPLE: 8-bit name decode encode ;

: encode-8-bit ( char stream assoc -- )
    swapd at* [ encode-error ] unless swap stream-write1 ;

M: 8-bit encode-char
    encode>> encode-8-bit ;

: decode-8-bit ( stream array -- char/f )
    swap stream-read1 dup
    [ swap nth [ replacement-char ] unless* ]
    [ nip ] if ;

M: 8-bit decode-char
    decode>> decode-8-bit ;

: make-8-bit ( word byte>ch ch>byte -- )
    [ 8-bit construct-boa ] 2curry dupd curry define ;

: define-8-bit-encoding ( name path -- )
    >r in get create r> parse-file make-8-bit ;

PRIVATE>

[
    "io.encodings.8-bit" in [
        mappings [ full-path define-8-bit-encoding ] assoc-each
    ] with-variable
] with-compilation-unit
