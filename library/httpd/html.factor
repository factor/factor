! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: html
USING: lists kernel namespaces stdio streams strings unparser
url-encoding presentation generic ;

: html-entities ( -- alist )
    [
        [[ CHAR: < "&lt;"   ]]
        [[ CHAR: > "&gt;"   ]]
        [[ CHAR: & "&amp;"  ]]
        [[ CHAR: ' "&apos;" ]]
        [[ CHAR: " "&quot;" ]]
    ] ;

: char>entity ( ch -- str )
    dup >r html-entities assoc dup r> ? ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [ dup html-entities assoc dup rot ? ] str-map ;

: >hex-color ( triplet -- hex )
    [ >hex 2 "0" pad ] map "#" swons cat ;

: fg-css, ( color -- )
    "color: " , >hex-color , "; " , ;

: bold-css, ( flag -- )
    [ "font-weight: bold; " , ] when ;

: italics-css, ( flag -- )
    [ "font-style: italic; " , ] when ;

: underline-css, ( flag -- )
    [ "text-decoration: underline; " , ] when ;

: size-css, ( size -- )
    "font-size: " , unparse , "; " , ;

: font-css, ( font -- )
    "font-family: " , , "; " , ;

: css-style ( style -- )
    [
        [
            [ "fg"        fg-css, ]
            [ "bold"      bold-css, ]
            [ "italics"   italics-css, ]
            [ "underline" underline-css, ]
            [ "size"      size-css, ]
            [ "font"      font-css, ]
        ] assoc-apply
    ] make-string ;

: span-tag ( style quot -- )
    over css-style dup "" = [
        drop call
    ] [
        <span style= span> call </span>
    ] ifte ;

: resolve-file-link ( path -- link )
    #! The file responder needs relative links not absolute
    #! links.
    "doc-root" get [
        ?str-head [ "/" ?str-head drop ] when
    ] when* "/" ?str-tail drop ;

: file-link-href ( path -- href )
    [ "/" , resolve-file-link url-encode , ] make-string ;

: file-link-tag ( style quot -- )
    over "file-link" swap assoc [
        <a href= file-link-href a> call </a>
    ] [
        call
    ] ifte* ;

: icon-tag ( string style quot -- )
    over "icon" swap assoc dup [
        <img src= "/responder/resource/" swap cat2 img/>
        #! Ignore the quotation, since no further style
        #! can be applied
        3drop
    ] [
        drop call
    ] ifte ;

TUPLE: html-stream delegate ;

M: html-stream fwrite-attr ( str style stream -- )
    wrapper-stream-scope [
        [
            [
                [ drop chars>entities write ] span-tag
            ] file-link-tag
        ] icon-tag
    ] bind ;

C: html-stream ( stream -- stream )
    #! Wraps the given stream in an HTML stream. An HTML stream
    #! converts special characters to entities when being
    #! written, and supports writing attributed strings with
    #! the following attributes:
    #!
    #! link - an object path
    #! fg - an rgb triplet in a list
    #! bg - an rgb triplet in a list
    #! bold
    #! italics
    #! underline
    #! size
    #! link - an object path
    [ >r <wrapper-stream> r> set-html-stream-delegate ] keep ;

: with-html-stream ( quot -- )
    [ stdio [ <html-stream> ] change  call ] with-scope ;

: html-document ( title quot -- )
    swap chars>entities dup
    <html>
        <head>
            <title> write </title>
        </head>
        <body>
            <h1> write </h1>
            call
        </body>
    </html> ;

: simple-html-document ( title quot -- )
    swap [ <pre> with-html-stream </pre> ] html-document ;
