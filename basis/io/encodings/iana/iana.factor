! Copyright (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: kernel strings io.files assocs
splitting sequences io namespaces sets
io.encodings.ascii io.encodings.utf8 io.encodings.utf16 ;
IN: io.encodings.iana

<PRIVATE
SYMBOL: n>e-table
SYMBOL: e>n-table
SYMBOL: aliases
PRIVATE>

: name>encoding ( name -- encoding )
    n>e-table get-global at ;

: encoding>name ( encoding -- name )
    e>n-table get-global at ;

<PRIVATE
: parse-iana ( file -- synonym-set )
    utf8 file-lines { "" } split [
        [ split-words ] map
        [ first { "Name:" "Alias:" } member? ] filter
        values { "None" } diff
    ] map harvest ;

: make-aliases ( file -- n>e )
    parse-iana [ [ first ] [ ] bi ] H{ } map>assoc ;

: initial-n>e ( -- assoc )
    H{
        { "UTF8" utf8 }
        { "utf8" utf8 }
        { "utf-8" utf8 }
        { "UTF-8" utf8 }
    } clone ;

: initial-e>n ( -- assoc )
    H{ { utf8 "UTF-8" } } clone ;

PRIVATE>

"vocab:io/encodings/iana/character-sets"
make-aliases aliases set-global

n>e-table [ initial-n>e ] initialize
e>n-table [ initial-e>n ] initialize

: register-encoding ( descriptor name -- )
    [
        aliases get at [
            [ n>e-table get-global set-at ] with each
        ] [ "Bad encoding registration" throw ] if*
    ] [ swap e>n-table get-global set-at ] 2bi ;

ascii "ANSI_X3.4-1968" register-encoding
utf16be "UTF-16BE" register-encoding
utf16le "UTF-16LE" register-encoding
utf16 "UTF-16" register-encoding
