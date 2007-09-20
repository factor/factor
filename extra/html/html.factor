! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: generic assocs help http io io.styles io.files io.streams.string
kernel math math.parser namespaces xml.writer quotations
assocs sequences strings words html.elements ;
IN: html

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

: hash-apply ( value-hash quot-hash -- )
    #! Looks up the key of each pair in the first list in the
    #! second list to produce a quotation. The quotation is
    #! applied to the value of the pair. If there is no
    #! corresponding quotation, the value is popped off the
    #! stack.
    [ swapd at dup [ call ] [ 2drop ] if ] curry assoc-each ;

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

: border-css, ( border -- )
    "border: 1px solid #" % hex-color, "; " % ;

: padding-css, ( padding -- ) "padding: " % # "px; " % ;

: pre-css, ( -- )
    "white-space: pre; font-family: monospace; " % ;

: div-css-style ( style -- str )
    [
        H{
            { page-color [ bg-css, ] }
            { border-color [ border-css, ] }
            { border-width [ padding-css, ] }
            { wrap-margin [ [ pre-css, ] unless ] }
        } hash-apply
    ] "" make ;

: div-tag ( style quot -- )
    swap div-css-style dup empty? [
        drop call
    ] [
        <div =style div> call </div>
    ] if ;

: do-escaping ( string style -- string )
    html swap at [ chars>entities ] unless ;

GENERIC: browser-link-href ( presented -- href )

M: object browser-link-href drop f ;

: object-link-tag ( style quot -- )
    presented pick at browser-link-href
    [ <a =href a> call </a> ] [ call ] if* ;

TUPLE: nested-stream ;

: <nested-stream> ( stream -- stream )
    nested-stream construct-delegate ;

M: nested-stream stream-close drop ;

TUPLE: html-stream ;

: <html-stream> ( stream -- stream )
    html-stream construct-delegate ;

M: html-stream stream-write1 ( char stream -- )
    >r 1string r> stream-write ;

: delegate-write delegate stream-write ;

M: html-stream stream-write ( str stream -- )
    >r chars>entities r> delegate-write ;

: with-html-style ( quot style stream -- )
    [ [ swap span-tag ] object-link-tag ] with-stream* ; inline

M: html-stream with-stream-style ( quot style stream -- )
    [ drop call ] -rot with-html-style ;

M: html-stream stream-format ( str style stream -- )
    [ do-escaping stdio get delegate-write ] -rot
    with-html-style ;

: with-html-stream ( quot -- )
    stdio get <html-stream> swap with-stream* ;

M: html-stream with-nested-stream ( quot style stream -- )
    [
        [
            [
                stdio get <nested-stream> swap with-stream*
            ] div-tag
        ] object-link-tag
    ] with-stream* ;

: border-spacing-css,
    "padding: " % first2 max 2 /i # "px; " % ;

: table-style ( style -- str )
    [
        H{
            { table-border [ border-css,         ] }
            { table-gap    [ border-spacing-css, ] }
        } hash-apply
    ] "" make ;

: table-attrs ( style -- )
    table-style " border-collapse: collapse;" append =style ;

M: html-stream stream-write-table ( grid style stream -- )
    [
        <table dup table-attrs table> swap [
            <tr> [
                <td "top" =valign swap table-style =style td>
                    write-html
                </td>
            ] curry* each </tr>
        ] curry* each </table>
    ] with-stream* ;

M: html-stream make-table-cell ( quot style stream -- table-cell )
    2drop [ with-html-stream ] string-out ;

M: html-stream stream-nl [ <br/> ] with-stream* ;

: default-css ( -- )
    <link
    "stylesheet" =rel "text/css" =type
    "/responder/resources/stylesheet.css" =href
    link/> ;

: xhtml-preamble
    "<?xml version=\"1.0\"?>" write-html
    "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" write-html ;

: html-document* ( body-quot head-quot -- )
    #! head-quot is called to produce output to go
    #! in the html head portion of the document.
    #! body-quot is called to produce output to go
    #! in the html body portion of the document.
    xhtml-preamble
    <html " xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"" write-html html>
        <head> call </head>
        <body> call </body>
    </html> ;
  
: html-document ( title quot -- )
    swap [
        <title> write </title>
        default-css
    ] html-document* ;

: simple-html-document ( title quot -- )
    swap [ <pre> with-html-stream </pre> ] html-document ;
