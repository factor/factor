! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings values io.files assocs
splitting sequences io namespaces sets io.encodings.utf8 ;
IN: io.encodings.iana

<PRIVATE
SYMBOL: n>e-table
SYMBOL: e>n-table
SYMBOL: aliases
PRIVATE>

ERROR: missing-encoding name ;

: name>encoding ( name -- encoding )
    dup n>e-table get-global at [ ] [ missing-encoding ] ?if ;

ERROR: missing-name encoding ;

: encoding>name ( encoding -- name )
    dup e>n-table get-global at [ ] [ missing-name ] ?if ;

<PRIVATE
: parse-iana ( file -- synonym-set )
    utf8 file-lines { "" } split [
        [ " " split ] map
        [ first { "Name:" "Alias:" } member? ] filter
        [ second ] map { "None" } diff
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
