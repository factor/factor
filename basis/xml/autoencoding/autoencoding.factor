! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces xml.name io.encodings.utf8 xml.elements
io.encodings.utf16 xml.tokenize xml.state math ascii sequences
io.encodings.string io.encodings combinators accessors
xml.data io.encodings.iana xml.errors ;
IN: xml.autoencoding

: decode-stream ( encoding -- )
    spot get [ swap re-decode ] change-stream drop ;

: continue-make-tag ( str -- tag )
    parse-name-starting middle-tag end-tag ;

: start-utf16le ( -- tag )
    utf16le decode-stream
    "?\0" expect
    check instruct ;

: 10xxxxxx? ( ch -- ? )
    -6 shift 3 bitand 2 = ;

: start<name ( ch -- tag )
    ! This is unfortunate, and exists for the corner case
    ! that the first letter of the document is < and second is
    ! not ASCII
    ascii?
    [ utf8 decode-stream next make-tag ] [
        next
        [ drop get-next 10xxxxxx? not ] take-until
        get-char suffix utf8 decode
        utf8 decode-stream next
        continue-make-tag
    ] if ;

: prolog-encoding ( prolog -- )
    encoding>> dup "UTF-16" =
    [ drop ] [
        [ name>encoding ] [ decode-stream ] [ bad-encoding ] ?if
    ] if ;

: instruct-encoding ( instruct/prolog -- )
    dup prolog?
    [ prolog-encoding ]
    [ drop utf8 decode-stream ] if ;

: go-utf8 ( -- )
    check utf8 decode-stream next next ;

: start< ( -- tag )
    ! What if first letter of processing instruction is non-ASCII?
    get-next {
        { 0 [ next next start-utf16le ] }
        { CHAR: ? [ go-utf8 instruct dup instruct-encoding ] }
        { CHAR: ! [ go-utf8 direct ] }
        [ check start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-stream
    "<" expect check make-tag ;

: decode-expecting ( encoding string -- tag )
    [ decode-stream next ] [ expect ] bi* check make-tag ;

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
        { 0xEF [ skip-utf8-bom ] }
        { 0xFF [ skip-utf16le-bom ] }
        { 0xFE [ skip-utf16be-bom ] }
        [ drop utf8 decode-stream check f ]
    } case ;
