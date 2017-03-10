! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs colors.constants formatting
html.entities html.parser html.parser.analyzer html.parser.printer
http.client io io.styles kernel namespaces sequences splitting urls
wrap.strings xml xml.data xml.traversal ;
FROM: xml.data => tag? ;

IN: wikipedia

SYMBOL: language
"en" language set-global

: with-language ( str quot -- )
    language swap with-variable ; inline

<PRIVATE

: wikipedia-url ( path -- url )
    language get swap "http://%s.wikipedia.org/wiki/%s" sprintf >url ;

: header. ( string -- )
    H{ { font-size 20 } { font-style bold } } format nl ;

: link ( tag -- tag/f )
    "a" assure-name over tag-named? [ "a" deep-tag-named ] unless ;

: link. ( tag -- )
    [ deep-children>string ] [ attrs>> "href" of ] bi
    wikipedia-url H{
        { font-name "monospace" }
        { foreground COLOR: blue }
    } [ write-object ] with-style ;

: item. ( tag -- )
    children>> [
        dup tag? [
            dup link [ link. drop ] [ children>string write ] if*
        ] [ [ write ] unless-empty ] if
    ] each nl ;

: items. ( seq -- )
    children-tags [ item. ] each nl ;

: historical-url ( timestamp -- url )
    "%B_%d" strftime wikipedia-url ;

: (historical-events) ( timestamp -- seq )
    historical-url http-get nip string>xml "ul" deep-tags-named ;

: items>sequence ( tag -- seq )
    children-tags [ deep-children>string ] map ;

PRIVATE>

: historical-events ( timestamp -- events )
    (historical-events) second items>sequence ;

: historical-events. ( timestamp -- )
    (historical-events) "Events" header. second items. ;

: historical-births ( timestamp -- births )
    (historical-events) third items>sequence ;

: historical-births. ( timestamp -- )
    (historical-events) "Births" header. third items. ;

: historical-deaths ( timestamp -- births )
    (historical-events) fourth items>sequence ;

: historical-deaths. ( timestamp -- )
    (historical-events) "Deaths" header. fourth items. ;

: article. ( name -- )
    wikipedia-url http-get nip parse-html
    "content" find-by-id-between
    html-text string-lines
    [ [ blank? ] trim ] map harvest [
        html-unescape 72 wrap-string print nl
    ] each ;
