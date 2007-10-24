! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: generic assocs help http io io.styles io.files
io.streams.string kernel math math.parser namespaces
quotations assocs sequences strings words html.elements
xml.writer sbufs ;
IN: html

GENERIC: browser-link-href ( presented -- href )

M: object browser-link-href drop f ;

TUPLE: html-stream ;

: <html-stream> ( stream -- stream )
    html-stream construct-delegate ;

<PRIVATE

TUPLE: html-sub-stream style stream ;

: (html-sub-stream) ( style stream -- stream )
    html-sub-stream construct-boa
    512 <sbuf> <html-stream> over set-delegate ;

: <html-sub-stream> ( style stream class -- stream )
    >r (html-sub-stream) r> construct-delegate ; inline

: end-sub-stream ( substream -- string style stream )
    dup delegate >string
    over html-sub-stream-style
    rot html-sub-stream-stream ;

: delegate-write ( string -- )
    stdio get delegate stream-write ;

: object-link-tag ( style quot -- )
    presented pick at [
        browser-link-href [
            <a =href a> call </a>
        ] [ call ] if*
    ] [ call ] if* ; inline

: hex-color, ( triplet -- )
    3 head-slice
    [ 255 * >fixnum >hex 2 CHAR: 0 pad-left % ] each ;

: fg-css, ( color -- )
    "color: #" % hex-color, "; " % ;

: bg-css, ( color -- )
    "background-color: #" % hex-color, "; " % ;

: style-css, ( flag -- )
    dup
    { italic bold-italic } member?
    "font-style: " % "italic" "normal" ? % "; " %
    { bold bold-italic } member?
    "font-weight: " % "bold" "normal" ? % "; " % ;

: size-css, ( size -- )
    "font-size: " % # "pt; " % ;

: font-css, ( font -- )
    "font-family: " % % "; " % ;

: apply-style ( style key quot -- style gadget )
    >r over at r> when* ; inline

: make-css ( style quot -- str )
    "" make nip ; inline

: span-css-style ( style -- str )
    [
        foreground [ fg-css,    ] apply-style
        background [ bg-css,    ] apply-style
        font       [ font-css,  ] apply-style
        font-style [ style-css, ] apply-style
        font-size  [ size-css,  ] apply-style
    ] make-css ;

: span-tag ( style quot -- )
    over span-css-style dup empty? [
        drop call
    ] [
        <span =style span> call </span>
    ] if ; inline

: format-html-span ( string style stream -- )
    [
        [ [ drop delegate-write ] span-tag ] object-link-tag
    ] with-stream* ;

TUPLE: html-span-stream ;

M: html-span-stream stream-close
    end-sub-stream format-html-span ;

: border-css, ( border -- )
    "border: 1px solid #" % hex-color, "; " % ;

: padding-css, ( padding -- ) "padding: " % # "px; " % ;

: pre-css, ( margin -- )
    [ "white-space: pre; font-family: monospace; " % ] unless ;

: div-css-style ( style -- str )
    [
        page-color   [ bg-css,      ] apply-style
        border-color [ border-css,  ] apply-style
        border-width [ padding-css, ] apply-style
        wrap-margin  [ pre-css,     ] apply-style
    ] make-css ;

: div-tag ( style quot -- )
    swap div-css-style dup empty? [
        drop call
    ] [
        <div =style div> call </div>
    ] if ; inline

: format-html-div ( string style stream -- )
    [
        [ [ delegate-write ] div-tag ] object-link-tag
    ] with-stream* ;

TUPLE: html-block-stream ;

M: html-block-stream stream-close ( quot style stream -- )
    end-sub-stream format-html-div ;

: border-spacing-css,
    "padding: " % first2 max 2 /i # "px; " % ;

: table-style ( style -- str )
    [
        table-border [ border-css,         ] apply-style
        table-gap    [ border-spacing-css, ] apply-style
    ] make-css ;

: table-attrs ( style -- )
    table-style " border-collapse: collapse;" append =style ;

: do-escaping ( string style -- string )
    html swap at [ chars>entities ] unless ;

PRIVATE>

! Stream protocol
M: html-stream stream-write1 ( char stream -- )
    >r 1string r> stream-write ;

M: html-stream stream-write ( str stream -- )
    >r chars>entities r> delegate stream-write ;

M: html-stream make-span-stream ( style stream -- stream' )
    html-span-stream <html-sub-stream> ;

M: html-stream stream-format ( str style stream -- )
    >r html over at [ >r chars>entities r> ] unless r>
    format-html-span ;

M: html-stream make-block-stream ( style stream -- stream' )
    html-block-stream <html-sub-stream> ;

M: html-stream stream-write-table ( grid style stream -- )
    [
        <table dup table-attrs table> swap [
            <tr> [
                <td "top" =valign swap table-style =style td>
                    >string write-html
                </td>
            ] curry* each </tr>
        ] curry* each </table>
    ] with-stream* ;

M: html-stream make-cell-stream ( style stream -- stream' )
    (html-sub-stream) ;

M: html-stream stream-nl ( stream -- )
    [ <br/> ] with-stream* ;

! Utilities
: with-html-stream ( quot -- )
    stdio get <html-stream> swap with-stream* ;

: xhtml-preamble
    "<?xml version=\"1.0\"?>" write-html
    "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" write-html ;

: html-document ( body-quot head-quot -- )
    #! head-quot is called to produce output to go
    #! in the html head portion of the document.
    #! body-quot is called to produce output to go
    #! in the html body portion of the document.
    xhtml-preamble
    <html "http://www.w3.org/1999/xhtml" =xmlns "en" =xml:lang "en" =lang html>
        <head> call </head>
        <body> call </body>
    </html> ;

: default-css ( -- )
    <link
    "stylesheet" =rel "text/css" =type
    "/responder/resources/extra/html/stylesheet.css" =href
    link/> ;

: simple-html-document ( title quot -- )
    swap [
        <title> write </title>
        default-css
    ] html-document ;
