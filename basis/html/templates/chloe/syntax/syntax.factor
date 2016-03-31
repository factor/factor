! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences combinators kernel namespaces classes.tuple
assocs splitting words arrays memoize parser lexer io io.files
io.encodings.utf8 io.streams.string unicode mirrors fry math urls
multiline xml xml.data xml.writer xml.syntax html.components
html.templates ;
IN: html.templates.chloe.syntax

SYMBOL: tags

tags [ H{ } clone ] initialize

: define-chloe-tag ( name quot -- ) swap tags get set-at ;

SYNTAX: CHLOE:
    scan-token parse-definition define-chloe-tag ;

CONSTANT: chloe-ns "http://factorcode.org/chloe/1.0"

: chloe-name? ( name -- ? )
    url>> chloe-ns = ;

XML-NS: chloe-name http://factorcode.org/chloe/1.0

: required-attr ( tag name -- value )
    [ nip ] [ chloe-name attr ] 2bi
    [ ] [ " attribute is required" append throw ] ?if ;

: optional-attr ( tag name -- value )
    chloe-name attr ;
