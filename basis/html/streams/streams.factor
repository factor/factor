! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators destructors fry html io
io.backend io.pathnames io.styles kernel macros make math
math.order math.parser namespaces sequences strings words
splitting xml xml.syntax ;
IN: html.streams

GENERIC: url-of ( object -- url )

M: object url-of drop f ;

TUPLE: html-writer data ;
INSTANCE: html-writer output-stream

<PRIVATE

: new-html-writer ( class -- html-writer )
    new V{ } clone >>data ; inline

TUPLE: html-sub-stream < html-writer style parent ;

: new-html-sub-stream ( style stream class -- stream )
    new-html-writer
        swap >>parent
        swap >>style ; inline

: end-sub-stream ( substream -- string style stream )
    [ data>> ] [ style>> ] [ parent>> ] tri ;

: object-link-tag ( xml style -- xml )
    presented of [ url-of [ simple-link ] when* ] when* ;

: href-link-tag ( xml style -- xml )
    href of [ simple-link ] when* ;

: hex-color, ( color -- )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * >integer >hex 2 CHAR: 0 pad-head % ] tri@ ;

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

MACRO: make-css ( pairs -- str )
    [ '[ _ of [ _ execute ] when* ] ] { } assoc>map
    '[ [ _ cleave ] "" make ] ;

: span-css-style ( style -- str )
    {
        { foreground fg-css, }
        { background bg-css, }
        { font-name font-css, }
        { font-style style-css, }
        { font-size size-css, }
    } make-css ;

: span-tag ( xml style -- xml )
    span-css-style
    [ swap [XML <span style=<->><-></span> XML] ] unless-empty ; inline

: emit-html ( stream quot -- )
    dip data>> push ; inline

: icon-path ( path -- icons-path )
    "vocab:definitions/icons/" ?head [ "/icons/" prepend ] when ;

: img-tag ( xml style -- xml )
    image-style of [ nip icon-path simple-image ] when* ;

: format-html-span ( string style stream -- )
    [
        {
            [ span-tag ]
            [ href-link-tag ]
            [ object-link-tag ]
            [ img-tag ]
        } cleave
    ] emit-html ;

TUPLE: html-span-stream < html-sub-stream ;

M: html-span-stream dispose
    end-sub-stream format-html-span ;

: border-css, ( border -- )
    "border: 1px solid #" % hex-color, "; " % ;

: (padding-css,) ( horizontal vertical -- )
    2dup = [
        drop "padding: " % # "px; " %
    ] [
        "padding: " % # "px " % # "px; " %
    ] if ;

: padding-css, ( padding -- )
    first2 (padding-css,) ;

CONSTANT: pre-css "white-space: pre; font-family: monospace; "

: div-css-style ( style -- str )
    [
        {
            { page-color bg-css, }
            { border-color border-css, }
            { inset padding-css, }
        } make-css
    ] [ wrap-margin of [ pre-css append ] unless ] bi
    "display: inline-block; " append ;

: div-tag ( xml style -- xml' )
    div-css-style
    [ swap [XML <div style=<->><-></div> XML] ] unless-empty ;

: format-html-div ( string style stream -- )
    [ [ div-tag ] [ object-link-tag ] bi ] emit-html ;

TUPLE: html-block-stream < html-sub-stream ;

M: html-block-stream dispose
    end-sub-stream format-html-div ;

: border-spacing-css, ( pair -- )
    first2 [ 2 /i ] bi@ (padding-css,) ;

: table-style ( style -- str )
    {
        { table-border border-css, }
        { table-gap border-spacing-css, }
    } make-css ;

PRIVATE>

! Stream protocol
M: html-writer stream-flush drop ;

M: html-writer stream-write1
    [ 1string ] emit-html ;

M: html-writer stream-write
    [ ] emit-html ;

M: html-writer stream-format
    format-html-span ;

M: html-writer stream-nl
    [ [XML <br/> XML] ] emit-html ;

M: html-writer make-span-stream
    html-span-stream new-html-sub-stream ;

M: html-writer make-block-stream
    html-block-stream new-html-sub-stream ;

M: html-writer make-cell-stream
    html-sub-stream new-html-sub-stream ;

M: html-writer stream-write-table
    [
        table-style swap [
            [ data>> [XML <td valign="top" style=<->><-></td> XML] ] with map
            [XML <tr><-></tr> XML]
        ] with map
        [XML <table style="display: inline-table; border-collapse: collapse;"><-></table> XML]
    ] emit-html ;

M: html-writer dispose drop ;

: <html-writer> ( -- html-writer )
    html-writer new-html-writer ;

: with-html-writer ( quot -- xml )
    <html-writer> [ swap with-output-stream* ] keep data>> ; inline
