! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: html
USING: #<unknown> generic http io kernel lists namespaces
presentation sequences strings styles unparser words ;

: html-entities ( -- alist )
    [
        [[ CHAR: < "&lt;"   ]]
        [[ CHAR: > "&gt;"   ]]
        [[ CHAR: & "&amp;"  ]]
        [[ CHAR: ' "&apos;" ]]
        [[ CHAR: " "&quot;" ]]
    ] ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [
        [ dup html-entities assoc [ % ] [ , ] ?ifte ] each
    ] make-string ;

: hex-color, ( triplet -- )
    [ >hex 2 CHAR: 0 pad-left % ] each ;

: fg-css, ( color -- )
    "color: #" % hex-color, "; " % ;

: style-css, ( flag -- )
    dup [ italic bold-italic ] member?
    [ "font-style: italic; " % ] when
    [ bold bold-italic ] member?
    [ "font-weight: bold; " % ] when ;

: underline-css, ( flag -- )
    [ "text-decoration: underline; " % ] when ;

: size-css, ( size -- )
    "font-size: " % unparse % "; " % ;

: font-css, ( font -- )
    "font-family: " % % "; " % ;

: css-style ( style -- )
    [
        [
            [ foreground  fg-css, ]
            [ font        font-css, ]
            [ font-style  style-css, ]
            [ font-size   size-css, ]
            [ underline   underline-css, ]
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
        ?head [ "/" ?head drop ] when
    ] when* "/" ?tail drop ;

: file-link-href ( path -- href )
    [ "/" % resolve-file-link url-encode % ] make-string ;

: file-link-tag ( style quot -- )
    over file swap assoc [
        <a href= file-link-href a> call </a>
    ] [
        call
    ] ifte* ;

: browser-link-href ( word -- href )
    dup word-name swap word-vocabulary
    [
        "/responder/browser/?vocab=" %
        url-encode %
        "&word=" %
        url-encode %
    ] make-string ;

: browser-link-tag ( style quot -- style )
    over presented swap assoc dup word? [
        <a href= browser-link-href a> call </a>
    ] [
        drop call
    ] ifte ;

: icon-tag ( string style quot -- )
    over icon swap assoc dup [
        <img src= "/responder/resource/" swap append img/>
        #! Ignore the quotation, since no further style
        #! can be applied
        3drop
    ] [
        drop call
    ] ifte ;

TUPLE: html-stream ;

M: html-stream stream-write1 ( char stream -- )
    [
        dup html-entities assoc [ write ] [ write1 ] ?ifte
    ] with-wrapper ;

M: html-stream stream-format ( str style stream -- )
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
    #! foreground - an rgb triplet in a list
    #! background - an rgb triplet in a list
    #! font
    #! font-style
    #! font-size
    #! underline
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
