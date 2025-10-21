! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays combinators continuations io io.encodings
io.encodings.ascii io.encodings.binary io.encodings.iana
io.encodings.latin1 io.encodings.string io.encodings.utf16
io.encodings.utf32 io.encodings.utf7 io.encodings.utf8 io.files
kernel literals math namespaces sequences strings ;
IN: io.encodings.detect

SYMBOL: default-encoding
default-encoding [ latin1 ] initialize

<PRIVATE

: prolog-tag ( bytes -- string )
    CHAR: > over index [ 1 + head-slice ] when* >string ;

: prolog-encoding ( string -- iana-encoding )
    '[
        _ dup "encoding=" subseq-index
        10 + swap [ [ 1 - ] dip nth ] [ index-from ] [ swapd subseq ] 2tri
    ] [ drop "UTF-8" ] recover ;

: detect-xml-prolog ( bytes -- encoding )
    prolog-tag prolog-encoding name>encoding [ ascii ] unless* ;

: valid-utf8? ( bytes -- ? )
    utf8 decode but-last-slice replacement-char swap member? not ;

PRIVATE>

: detect-byte-array ( bytes -- encoding )
    {
        { [ dup B{ 0x00 0x00 0xFE 0xFF } head? ] [ drop utf32be ] }
        { [ dup B{ 0xFF 0xFE 0x00 0x00 } head? ] [ drop utf32le ] }
        { [ dup B{ 0xFE 0xFF } head? ] [ drop utf16be ] }
        { [ dup B{ 0xFF 0xFE } head? ] [ drop utf16le ] }
        { [ dup B{ 0xEF 0xBB 0xBF } head? ] [ drop utf8 ] }
        { [ dup B{ 0x2B 0x2F 0x76 } head? ] [ drop utf7 ] }
        { [ dup $[ "<?xml" >byte-array ] head? ] [ detect-xml-prolog ] }
        { [ 0 over member? ] [ drop binary ] }
        { [ dup empty? ] [ drop utf8 ] }
        { [ dup valid-utf8? ] [ drop utf8 ] }
        [ drop default-encoding get ]
    } cond ;

: detect-stream ( stream -- sample encoding )
    256 swap stream-read dup detect-byte-array ;

: detect-file ( file -- encoding )
    binary [ input-stream get detect-stream nip ] with-file-reader ;
