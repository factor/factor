! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces xml.name io.encodings.utf8 xml.elements
io.encodings.utf16 xml.tokenize xml.state math ascii sequences
io.encodings.string io.encodings combinators ;
IN: xml.autoencoding

: continue-make-tag ( str -- tag )
    parse-name-starting middle-tag end-tag ;

: start-utf16le ( -- tag )
    utf16le decode-input-if
    CHAR: ? expect
    0 expect check instruct ;

: 10xxxxxx? ( ch -- ? )
    -6 shift 3 bitand 2 = ;
          
: start<name ( ch -- tag )
    ascii?
    [ utf8 decode-input-if next make-tag ] [
        next
        [ get-next 10xxxxxx? not ] take-until
        get-char suffix utf8 decode
        utf8 decode-input-if next
        continue-make-tag
    ] if ;
          
: start< ( -- tag )
    get-next {
        { 0 [ next next start-utf16le ] }
        { CHAR: ? [ check next next instruct ] } ! XML prolog parsing sets the encoding
        { CHAR: ! [ check utf8 decode-input next next direct ] }
        [ check start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-input
    CHAR: < expect check make-tag ;

: decode-expecting ( encoding string -- tag )
    [ decode-input-if next ] [ expect-string ] bi* check make-tag ;

: start-utf16be ( -- tag )
    utf16be "<" decode-expecting ;

: skip-utf16le-bom ( -- tag )
    utf16le "\u0000fe<" decode-expecting ;

: skip-utf16be-bom ( -- tag )
    utf16be "\u0000ff<" decode-expecting ;

: start-document ( -- tag )
    get-char {
        { CHAR: < [ start< ] }
        { 0 [ start-utf16be ] }
        { HEX: EF [ skip-utf8-bom ] }
        { HEX: FF [ skip-utf16le-bom ] }
        { HEX: FE [ skip-utf16be-bom ] }
        { f [ "" ] }
        [ drop utf8 decode-input-if f ]
        ! Same problem as with <e`>, in the case of XML chunks?
    } case check ;

