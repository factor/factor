! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: html.templates.chloe.syntax
USING: accessors kernel sequences combinators kernel namespaces
classes.tuple assocs splitting words arrays memoize parser lexer
io io.files io.encodings.utf8 io.streams.string
unicode.case mirrors fry math urls
multiline xml xml.data xml.writer xml.utilities
html.elements
html.components
html.templates ;

SYMBOL: tags

tags global [ H{ } clone or ] change-at

: define-chloe-tag ( name quot -- ) swap tags get set-at ;

: CHLOE:
    scan parse-definition define-chloe-tag ; parsing

: chloe-ns "http://factorcode.org/chloe/1.0" ; inline

: chloe-name ( string -- name )
    name new
        swap >>main
        chloe-ns >>url ;

: required-attr ( tag name -- value )
    dup chloe-name rot at*
    [ nip ] [ drop " attribute is required" append throw ] if ;

: optional-attr ( tag name -- value )
    chloe-name swap at ;
