! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences combinators fry
namespaces make classes.tuple assocs splitting words arrays io
io.files io.files.info io.encodings.utf8 io.streams.string
unicode.case mirrors math urls present multiline quotations xml
logging
xml.writer xml.syntax strings
html.forms
html
html.components
html.templates
html.templates.chloe.compiler
html.templates.chloe.components
html.templates.chloe.syntax ;
IN: html.templates.chloe

TUPLE: chloe path ;

C: <chloe> chloe

CHLOE: chloe compile-children ;

CHLOE: title compile-children>string [ set-title ] [code] ;

CHLOE: write-title
    drop
    "head" tag-stack get member?
    "title" tag-stack get member? not and
    [ get-title [XML <title><-></title> XML] ]
    [ get-title ] ?
    [xml-code] ;

CHLOE: style
    dup "include" optional-attr [
        utf8 file-contents [ add-style ] [code-with]
    ] [
        compile-children>string [ add-style ] [code]
    ] ?if ;

CHLOE: write-style
    drop [
        get-style
        [XML <style type="text/css"> <-> </style> XML]
    ] [xml-code] ;

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

CHLOE: validation-errors
    drop [ render-validation-errors ] [code] ;

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

COMPONENT: label
COMPONENT: link
COMPONENT: inspector
COMPONENT: comparison
COMPONENT: html
COMPONENT: hidden
COMPONENT: farkup
COMPONENT: field
COMPONENT: textarea
COMPONENT: password
COMPONENT: choice
COMPONENT: checkbox
COMPONENT: code
COMPONENT: xml

SYMBOL: template-cache

H{ } template-cache set-global

TUPLE: cached-template path last-modified quot ;

: load-template ( chloe -- cached-template )
    path>> ".xml" append
    [ ]
    [ file-info modified>> ]
    [ file>xml compile-template ] tri
    \ cached-template boa ;

\ load-template DEBUG add-input-logging

: cached-template ( chloe -- cached-template/f )
    template-cache get at* [
        [
            [ path>> file-info modified>> ]
            [ last-modified>> ]
            bi =
        ] keep and
    ] when ;

: template-quot ( chloe -- quot )
    dup cached-template [ ] [
        [ load-template dup ] keep
        template-cache get set-at
    ] ?if quot>> ;

: reset-cache ( -- )
    template-cache get clear-assoc ;

M: chloe call-template*
    template-quot call( -- ) ;

INSTANCE: chloe template
