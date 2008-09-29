! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings values io.files assocs
splitting sequences io namespaces sets io.encodings.8-bit
io.encodings.ascii io.encodings.utf8 io.encodings.utf16  ;
IN: io.encodings.iana

<PRIVATE
VALUE: n>e-table

: e>n-table H{
    { ascii "US-ASCII" }
    { utf8 "UTF-8" }
    { utf16 "UTF-16" }
    { utf16be "UTF-16BE" }
    { utf16le "UTF-16LE" }
    { latin1 "ISO-8859-1" }
    { latin2 "ISO-8859-2" }
    { latin3 "ISO-8859-3" }
    { latin4 "ISO-8859-4" }
    { latin/cyrillic "ISO-8859-5" }
    { latin/arabic "ISO-8859-6" }
    { latin/greek "ISO-8859-7" }
    { latin/hebrew "ISO-8859-8" }
    { latin5 "ISO-8859-9" }
    { latin6 "ISO-8859-10" }
} ;
PRIVATE>

: name>encoding ( name -- encoding )
    n>e-table at ;

: encoding>name ( encoding -- name )
    e>n-table at ;

<PRIVATE
: parse-iana ( stream -- synonym-set )
    lines { "" } split [
        [ " " split ] map
        [ first { "Name:" "Alias:" } member? ] filter
        [ second ] map { "None" } diff
    ] map ;

: more-aliases ( -- assoc )
    H{
        { "UTF8" utf8 }
        { "utf8" utf8 }
        { "utf-8" utf8 }
    } ;

: make-n>e ( stream -- n>e )
    parse-iana [ [
        dup [
            e>n-table value-at
            [ swap [ set ] with each ]
            [ drop ] if*
        ] with each
    ] each ] H{ } make-assoc more-aliases assoc-union ;
PRIVATE>

"resource:basis/io/encodings/iana/character-sets"
ascii <file-reader> make-n>e to: n>e-table
