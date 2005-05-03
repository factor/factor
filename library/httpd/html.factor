! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: html
USING: generic kernel lists namespaces presentation sequences
stdio streams strings unparser http ;

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
    [
        [
            dup html-entities assoc [ % ] [ , ] ?ifte
        ] seq-each
    ] make-string ;

: >hex-color ( triplet -- hex )
    [ CHAR: # , [ >hex 2 CHAR: 0 pad % ] each ] make-string ;

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
        ?string-head [ "/" ?string-head drop ] when
    ] when* "/" ?string-tail drop ;

: file-link-href ( path -- href )
    [ "/" , resolve-file-link url-encode , ] make-string ;

: file-link-tag ( style quot -- )
    over "file" swap assoc [
        <a href= file-link-href a> call </a>
    ] [
        call
    ] ifte* ;

: browser-link-href ( style -- href )
    dup "word" swap assoc url-encode
    swap "vocab" swap assoc url-encode
    [ "/responder/browser/?vocab=" , , "&word=" , , ] make-string ;

: browser-link-tag ( style quot -- style )
    over "browser-link-word" swap assoc [
        <a href= over browser-link-href a> call </a>
    ] [
        call
    ] ifte ;

: icon-tag ( string style quot -- )
    over "icon" swap assoc dup [
        <img src= "/responder/resource/" swap cat2 img/>
        #! Ignore the quotation, since no further style
        #! can be applied
        3drop
    ] [
        drop call
    ] ifte ;

TUPLE: html-stream ;

M: html-stream stream-write-attr ( str style stream -- )
    [
        [
            [
                [
                    [ drop chars>entities write ] span-tag
                ] file-link-tag
            ] icon-tag
        ] browser-link-tag
    ] with-wrapper ;

C: html-stream ( stream -- stream )
    #! Wraps the given stream in an HTML stream. An HTML stream
    #! converts special characters to entities when being
    #! written, and supports writing attributed strings with
    #! the following attributes:
    #!
    #! fg - an rgb triplet in a list
    #! bg - an rgb triplet in a list
    #! bold
    #! italics
    #! underline
    #! size
    #! icon
    #! file
    #! word
    #! vocab
    [ >r <wrapper-stream> r> set-delegate ] keep ;

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
