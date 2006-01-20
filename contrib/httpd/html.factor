! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: html
USING: generic hashtables help http io kernel lists math
namespaces sequences strings styles words xml ;

: hex-color, ( triplet -- )
    3 swap head [ 255 * >fixnum >hex 2 CHAR: 0 pad-left % ] each ;

: fg-css, ( color -- ) "color: #" % hex-color, "; " % ;

: bg-css, ( color -- ) "background-color: #" % hex-color, "; " % ;

: style-css, ( flag -- )
    dup
    { italic bold-italic } member?
    [ "font-style: italic; " % ] when
    { bold bold-italic } member?
    [ "font-weight: bold; " % ] when ;

: size-css, ( size -- )
    "font-size: " % # "pt; " % ;

: font-css, ( font -- )
    "font-family: " % % "; " % ;

: hash-apply ( value-hash quot-hash -- )
    #! Looks up the key of each pair in the first list in the
    #! second list to produce a quotation. The quotation is
    #! applied to the value of the pair. If there is no
    #! corresponding quotation, the value is popped off the
    #! stack.
    swap [
        swap rot hash dup [ call ] [ 2drop ] if
    ] hash-each-with ;

: span-css-style ( style -- str )
    [
        H{
            { foreground  [ fg-css,        ] }
            { background  [ bg-css,        ] }
            { font        [ font-css,      ] }
            { font-style  [ style-css,     ] }
            { font-size   [ size-css,      ] }
        } hash-apply
    ] "" make ;

: span-tag ( style quot -- )
    over span-css-style dup empty? [
        drop call
    ] [
        <span =style span> call </span>
    ] if ;

: div-css-style ( style -- str )
    drop "" ;
    ! [
    !     H{
    !         { foreground  [ fg-css,        ] }
    !         { font        [ font-css,      ] }
    !         { font-style  [ style-css,     ] }
    !         { font-size   [ size-css,      ] }
    !     } hash-apply
    ! ] "" make ;

: div-tag ( style quot -- )
    over div-css-style dup empty? [
        drop call
    ] [
        <div =style div> call </div>
    ] if ;

: resolve-file-link ( path -- link )
    #! The file responder needs relative links not absolute
    #! links.
    "doc-root" get [
        ?head [ "/" ?head drop ] when
    ] when* "/" ?tail drop ;

: file-link-href ( path -- href )
    [ "/" % resolve-file-link url-encode % ] "" make ;

: file-link-tag ( style quot -- )
    over file swap hash [
        <a file-link-href =href a> call </a>
    ] [
        call
    ] if* ;

GENERIC: browser-link-href ( presented -- href )

M: word browser-link-href
    dup word-name swap word-vocabulary [
        "/responder/browser/?vocab=" %
        url-encode %
        "&word=" %
        url-encode %
    ] "" make ;

M: link browser-link-href
    link-name [ \ f ] unless* dup word? [
        browser-link-href
    ] [
        [ "/responder/help/" % url-encode % ] "" make
    ] if ;

M: object browser-link-href
    drop f ;

: browser-link-tag ( style quot -- style )
    presented pick hash browser-link-href
    [ <a =href a> call </a> ] [ call ] if* ;

TUPLE: wrapper-stream scope ;

C: wrapper-stream ( stream -- stream )
    2dup set-delegate [
        >r stdio associate r> set-wrapper-stream-scope
    ] keep ;

: with-wrapper ( stream quot -- )
    >r wrapper-stream-scope r> bind ; inline

TUPLE: nested-stream ;

C: nested-stream [ set-delegate ] keep ;

M: nested-stream stream-close drop ;

TUPLE: html-stream ;

M: html-stream stream-write1 ( char stream -- )
    >r ch>string r> stream-write ;

M: html-stream stream-write ( char stream -- )
    [ chars>entities write ] with-wrapper ;

M: html-stream stream-format ( str style stream -- )
    [
        [
            [
                [ drop chars>entities write ] span-tag
            ] file-link-tag
        ] browser-link-tag
    ] with-wrapper ;

: pre-tag ( stream style quot -- )
    wrap-margin rot hash [
        call
    ] [
        over [ [ <pre> ] with-wrapper call ] keep
        [ </pre> ] with-wrapper
    ] if ;

M: html-stream with-nested-stream ( quot style stream -- )
    swap [
        [ <nested-stream> swap with-stream ] pre-tag
    ] div-tag ;

M: html-stream stream-terpri [ <br/> ] with-wrapper ;

M: html-stream stream-terpri* [ <br/> ] with-wrapper ;

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
