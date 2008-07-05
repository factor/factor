! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: generic assocs help http io io.styles io.files continuations
io.streams.string kernel math math.order math.parser namespaces
quotations assocs sequences strings words html.elements
xml.entities sbufs continuations destructors accessors ;
IN: html.streams

GENERIC: browser-link-href ( presented -- href )

M: object browser-link-href drop f ;

TUPLE: html-stream stream last-div ;

! stream-nl after with-nesting or tabular-output is
! ignored, so that HTML stream output looks like
! UI pane output
: last-div? ( stream -- ? )
    [ f ] change-last-div drop ;

: not-a-div ( stream -- stream )
    f >>last-div ; inline

: a-div ( stream -- straem )
    t >>last-div ; inline

: <html-stream> ( stream -- stream )
    f html-stream boa ;

<PRIVATE

TUPLE: html-sub-stream < html-stream style parent ;

: new-html-sub-stream ( style stream class -- stream )
    new
        512 <sbuf> >>stream
        swap >>parent
        swap >>style ; inline

: end-sub-stream ( substream -- string style stream )
    [ stream>> >string ] [ style>> ] [ parent>> ] tri ;

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
    stream>> [
        [ [ drop write ] span-tag ] object-link-tag
    ] with-output-stream* ;

TUPLE: html-span-stream < html-sub-stream ;

M: html-span-stream dispose
    end-sub-stream not-a-div format-html-span ;

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
        wrap-margin over at pre-css,
    ] make-css ;

: div-tag ( style quot -- )
    swap div-css-style dup empty? [
        drop call
    ] [
        <div =style div> call </div>
    ] if ; inline

: format-html-div ( string style stream -- )
    stream>> [
        [ [ write ] div-tag ] object-link-tag
    ] with-output-stream* ;

TUPLE: html-block-stream < html-sub-stream ;

M: html-block-stream dispose ( quot style stream -- )
    end-sub-stream a-div format-html-div ;

: border-spacing-css, ( pair -- )
    "padding: " % first2 max 2 /i # "px; " % ;

: table-style ( style -- str )
    [
        table-border [ border-css,         ] apply-style
        table-gap    [ border-spacing-css, ] apply-style
    ] make-css ;

: table-attrs ( style -- )
    table-style " border-collapse: collapse;" append =style ;

: do-escaping ( string style -- string )
    html swap at [ escape-string ] unless ;

PRIVATE>

! Stream protocol
M: html-stream stream-flush
    stream>> stream-flush ;

M: html-stream stream-write1
    >r 1string r> stream-write ;

M: html-stream stream-write
    not-a-div >r escape-string r> stream>> stream-write ;

M: html-stream stream-format
    >r html over at [ >r escape-string r> ] unless r>
    format-html-span ;

M: html-stream stream-nl
    dup last-div? [ drop ] [ [ <br/> ] with-output-stream* ] if ;

M: html-stream make-span-stream
    html-span-stream new-html-sub-stream ;

M: html-stream make-block-stream
    html-block-stream new-html-sub-stream ;

M: html-stream make-cell-stream
    html-sub-stream new-html-sub-stream ;

M: html-stream stream-write-table
    a-div stream>> [
        <table dup table-attrs table> swap [
            <tr> [
                <td "top" =valign swap table-style =style td>
                    stream>> >string write
                </td>
            ] with each </tr>
        ] with each </table>
    ] with-output-stream* ;

M: html-stream dispose stream>> dispose ;

: with-html-stream ( quot -- )
    output-stream get <html-stream> swap with-output-stream* ; inline
