! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs calendar colors.constants
formatting html.parser html.parser.analyzer html.parser.printer
http.client io io.streams.string io.styles kernel make regexp
sequences splitting urls wrap.strings xml xml.data
xml.traversal ;
FROM: xml.data => tag? ;

IN: wikipedia

<PRIVATE

: header. ( string -- )
    H{ { font-size 20 } { font-style bold } } format nl ;

: link ( tag -- tag/f )
    "a" assure-name over tag-named? [ "a" deep-tag-named ] unless ;

: link. ( tag -- )
    [ deep-children>string ] [ attrs>> "href" of ] bi
    "http://en.wikipedia.org" prepend >url H{
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
    [ month-name ] [ day>> ] bi
    "http://en.wikipedia.org/wiki/%s_%s" sprintf ;

: (historical-events) ( timestamp -- seq )
    historical-url http-get* string>xml "ul" deep-tags-named ;

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
    "http://en.wikipedia.org/wiki/%s" sprintf
    http-get* parse-html "content" find-by-id-between
    [ html-text. ] with-string-writer string-lines
    [ [ blank? ] trim ] map harvest [
        R/ &lt;/ "<" re-replace
        R/ &gt;/ ">" re-replace
        R/ &amp;/ "&" re-replace
        72 wrap-string print nl
    ] each ;
