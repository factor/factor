! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: html.templates.chloe.syntax
USING: accessors kernel sequences combinators kernel namespaces
classes.tuple assocs splitting words arrays memoize parser
io io.files io.encodings.utf8 io.streams.string
unicode.case tuple-syntax mirrors fry math urls
multiline xml xml.data xml.writer xml.utilities
html.elements
html.components
html.templates ;

SYMBOL: tags

tags global [ H{ } clone or ] change-at

: define-chloe-tag ( name quot -- ) tags get set-at ;

: CHLOE:
    scan parse-definition swap define-chloe-tag ;
    parsing

: chloe-ns "http://factorcode.org/chloe/1.0" ; inline

MEMO: chloe-name ( string -- name )
    name new
        swap >>tag
        chloe-ns >>url ;

: required-attr ( tag name -- value )
    dup chloe-name rot at*
    [ nip ] [ drop " attribute is required" append throw ] if ;

: optional-attr ( tag name -- value )
    chloe-name swap at ;

: singleton-component-tag ( tag class -- )
    [ "name" required-attr ] dip render ;

: CHLOE-SINGLETON:
    scan dup '[ , singleton-component-tag ] define-chloe-tag ;
    parsing

: attrs>slots ( tag tuple -- )
    [ attrs>> ] [ <mirror> ] bi*
    '[
        swap tag>> dup "name" =
        [ 2drop ] [ , set-at ] if
    ] assoc-each ;

: tuple-component-tag ( tag class -- )
    [ drop "name" required-attr ]
    [ new [ attrs>slots ] keep ]
    2bi render ;

: CHLOE-TUPLE:
    scan dup '[ , tuple-component-tag ] define-chloe-tag ;
    parsing
