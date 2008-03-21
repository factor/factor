! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser arrays io.encodings sequences kernel
assocs hashtables io.encodings.ascii combinators.cleave
generic parser tuples words io io.files splitting namespaces
classes quotations ;
IN: io.encodings.8-bit

<PRIVATE

: mappings {
    { "iso-8859-1" "8859-1" }
    { "iso-8859-2" "8859-2" }
    { "iso-8859-3" "8859-3" }
    { "iso-8859-4" "8859-4" }
    { "iso-8859-5" "8859-5" }
    { "iso-8859-6" "8859-6" }
    { "iso-8859-7" "8859-7" }
    { "iso-8859-8" "8859-8" }
    { "iso-8859-9" "8859-9" }
    { "iso-8859-10" "8859-10" }
    { "iso-8859-11" "8859-11" }
    { "iso-8859-13" "8859-13" }
    { "iso-8859-14" "8859-14" }
    { "iso-8859-15" "8859-15" }
    { "iso-8859-16" "8859-16" }
    { "koi8-r" "KOI8-R" }
!    { "windows-1252" "CP1252" }
!    { "ebcdic" "CP037" }
    { "mac-roman" "ROMAN" }
!    { "gsm-03.38" "GSM0338" }
} ;

: full-path ( file-name -- path )
    "extra/io/encodings/8-bit/" ".TXT"
    swapd 3append resource-path ;

: process-contents ( lines -- assoc )
    [ "#" split first ] map
    [ empty? not ] subset
    [ "\t " split 2 head [ 2 tail hex> ] map ] map ;

: byte>ch ( assoc -- array )
    256 replacement-char <array>
    [ [ swapd set-nth ] curry assoc-each ] keep ;

: ch>byte ( assoc -- newassoc )
    [ swap ] assoc-map >hashtable ;

: parse-file ( file-name -- byte>ch ch>byte )
    full-path ascii file-lines process-contents
    [ byte>ch ] [ ch>byte ] bi ;

: empty-tuple-class ( string -- class )
    in get create
    dup { f } "slots" set-word-prop
    dup predicate-word drop
    dup { } define-tuple-class ;

: data-quot ( class word data -- quot )
    >r [ word-name ] 2apply "/" swap 3append
    "/data" append in get create dup 1quotation swap r>
    1quotation define ;

: method-with-data ( class data word quot -- )
    >r swap >r 2dup r> data-quot r>
    compose >r create-method r> define ;

: encode-8-bit ( char stream encoding assoc -- )
    nip swapd at* [ encode-error ] unless swap stream-write1 ;

: define-encode-char ( class assoc -- )
    \ encode-char [ encode-8-bit ] method-with-data ;

: decode-8-bit ( stream encoding array -- char/f )
    nip swap stream-read1 [ swap nth ] [ drop f ] if* ;

: define-decode-char ( class array -- )
    \ decode-char [ decode-8-bit ] method-with-data ;

: 8-bit-methods ( class byte>ch ch>byte -- )
    >r over r> define-encode-char define-decode-char ;

: define-8-bit-encoding ( tuple-name file-name -- )
    >r empty-tuple-class r> parse-file 8-bit-methods ;

PRIVATE>

! << mappings [ define-8-bit-encoding ] assoc-each >>
