! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences combinators kernel fry
namespaces classes.tuple assocs splitting words arrays memoize
io io.files io.encodings.utf8 io.streams.string unicode.case
mirrors math urls present multiline quotations xml xml.data
html.forms
html.elements
html.components
html.templates
html.templates.chloe.compiler
html.templates.chloe.components
html.templates.chloe.syntax ;
IN: html.templates.chloe

! Chloe is Ed's favorite web designer
TUPLE: chloe path ;

C: <chloe> chloe

CHLOE: chloe compile-children ;

CHLOE: title compile-children>string [ set-title ] [code] ;

CHLOE: write-title
    drop
    "head" tag-stack get member?
    "title" tag-stack get member? not and
    [ <title> write-title </title> ] [ write-title ] ? [code] ;

CHLOE: style
    dup "include" optional-attr [
        utf8 file-contents [ add-style ] [code-with]
    ] [
        compile-children>string [ add-style ] [code]
    ] ?if ;

CHLOE: write-style
    drop [ <style> write-style </style> ] [code] ;

CHLOE: even
    [ "index" value even? swap when ] process-children ;

CHLOE: odd
    [ "index" value odd? swap when ] process-children ;

: (bind-tag) ( tag quot -- )
    [
        [ "name" required-attr compile-attr ] keep
    ] dip process-children ; inline

CHLOE: each [ with-each-value ] (bind-tag) ;

CHLOE: bind-each [ with-each-object ] (bind-tag) ;

CHLOE: bind [ with-form ] (bind-tag) ;

CHLOE: comment drop ;

CHLOE: call-next-template
    drop reset-buffer \ call-next-template , ;

: attr>word ( value -- word/f )
    ":" split1 swap lookup ;

: if>quot ( tag -- quot )
    [
        [ "code" optional-attr [ attr>word [ , ] [ f , ] if* ] [ t , ] if* ]
        [ "value" optional-attr [ , \ value , ] [ t , ] if* ]
        bi
        \ and ,
    ] [ ] make ;

CHLOE: if dup if>quot [ swap when ] append process-children ;

CHLOE-SINGLETON: label
CHLOE-SINGLETON: link
CHLOE-SINGLETON: inspector
CHLOE-SINGLETON: comparison
CHLOE-SINGLETON: html
CHLOE-SINGLETON: hidden

CHLOE-TUPLE: farkup
CHLOE-TUPLE: field
CHLOE-TUPLE: textarea
CHLOE-TUPLE: password
CHLOE-TUPLE: choice
CHLOE-TUPLE: checkbox
CHLOE-TUPLE: code

: read-template ( chloe -- xml )
    path>> ".xml" append utf8 <file-reader> read-xml ;

MEMO: template-quot ( chloe -- quot )
    read-template compile-template ;

MEMO: nested-template-quot ( chloe -- quot )
    read-template compile-nested-template ;

: reset-templates ( -- )
    { template-quot nested-template-quot } [ reset-memoized ] each ;

M: chloe call-template*
    nested-template? get
    [ nested-template-quot ] [ template-quot ] if
    assert-depth ;

INSTANCE: chloe template
