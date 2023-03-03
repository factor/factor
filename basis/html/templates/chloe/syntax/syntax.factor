! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel lexer namespaces parser sequences
xml.data xml.syntax ;
IN: html.templates.chloe.syntax

SYMBOL: chloe-tags

chloe-tags [ H{ } clone ] initialize

: define-chloe-tag ( name quot -- ) swap chloe-tags get set-at ;

SYNTAX: CHLOE:
    scan-token parse-definition define-chloe-tag ;

CONSTANT: chloe-ns "http://factorcode.org/chloe/1.0"

: chloe-name? ( name -- ? )
    url>> chloe-ns = ;

XML-NS: chloe-name http://factorcode.org/chloe/1.0

: required-attr ( tag name -- value )
    [ nip ] [ chloe-name attr ] 2bi or*
    [ " attribute is required" append throw ] unless ;

: optional-attr ( tag name -- value )
    chloe-name attr ;
