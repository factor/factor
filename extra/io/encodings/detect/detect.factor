! (c)2010 Joe Groff bsd license
USING: accessors byte-arrays byte-arrays.hex combinators
continuations fry io io.encodings io.encodings.8-bit.latin1
io.encodings.ascii io.encodings.binary io.encodings.iana
io.encodings.string io.encodings.utf16 io.encodings.utf32
io.encodings.utf8 io.files io.streams.string kernel literals
math namespaces sequences strings ;
IN: io.encodings.detect

SYMBOL: default-8bit-encoding
default-8bit-encoding [ latin1 ] initialize

<PRIVATE

: prolog-tag ( bytes -- string )
    CHAR: > over index [ 1 + head-slice ] when* >string ;

: prolog-encoding ( string -- iana-encoding )
    '[
        _ "encoding=" over start
        10 + swap [ [ 1 - ] dip nth ] [ index-from ] [ swapd subseq ] 2tri
    ] [ drop "UTF-8" ] recover ;

: detect-xml-prolog ( bytes -- encoding )
    prolog-tag prolog-encoding name>encoding [ ascii ] unless* ;

: valid-utf8? ( bytes -- ? )
    utf8 decode 1 head-slice* replacement-char swap member? not ;

PRIVATE>

: detect-byte-array ( bytes -- encoding )
    {
        { [ dup HEX{ 0000FEFF } head? ] [ drop utf32be ] }
        { [ dup HEX{ FFFE0000 } head? ] [ drop utf32le ] }
        { [ dup HEX{ FEFF } head? ] [ drop utf16be ] }
        { [ dup HEX{ FFFE } head? ] [ drop utf16le ] }
        { [ dup HEX{ EF BB BF } head? ] [ drop utf8 ] }
        { [ dup $[ "<?xml" >byte-array ] head? ] [ detect-xml-prolog ] }
        { [ 0 over member? ] [ drop binary ] }
        { [ dup empty? ] [ drop utf8 ] }
        { [ dup valid-utf8? ] [ drop utf8 ] }
        [ drop default-8bit-encoding get ]
    } cond ;

: detect-stream ( stream -- sample encoding )
    256 swap stream-read dup detect-byte-array ;

: detect-file ( file -- encoding )
    binary [ input-stream get detect-stream nip ] with-file-reader ;
