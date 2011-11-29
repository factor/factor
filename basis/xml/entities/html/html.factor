! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.encodings.binary io.files kernel namespaces sequences
xml xml.entities accessors xml.state ;
IN: xml.entities.html

SYMBOL: html-entities

: read-entities-file ( file -- table )
    file>dtd entities>> ;

: get-html ( -- table )
    { "lat1" "special" "symbol" } [
        "vocab:xml/entities/html/xhtml-" ".ent" surround
        read-entities-file
    ] map first3 assoc-union assoc-union ;

get-html html-entities set-global

: with-html-entities ( quot -- )
    html-entities get-global swap with-entities ; inline
