! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs calendar colors combinators
command-line eval formatting html.entities html.parser
html.parser.analyzer html.parser.printer http.client io
io.styles kernel namespaces parser regexp sequences splitting
urls wrap.strings xml xml.data xml.traversal ;
FROM: xml.data => tag? ;

IN: wikipedia

SYMBOL: language
language [ "en" ] initialize

: with-language ( str quot -- )
    language swap with-variable ; inline

<PRIVATE

: wikipedia-url ( path -- url )
    language get swap "https://%s.wikipedia.org/%s?action=render" sprintf >url ;

: header. ( string -- )
    H{ { font-size 20 } { font-style bold } } format nl ;

: subheader. ( string -- )
    H{ { font-size 16 } { font-style bold } } format nl ;

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
            dup link [
                link. drop
            ] [
                children>string write
            ] if*
        ] [
            [ R/ \s+/ " " re-replace write ] unless-empty
        ] if
    ] each nl ;

: items. ( seq -- )
    children-tags [ item. ] each nl ;

: items>sequence ( tag -- seq )
    children-tags [ deep-children>string ] map ;

: sections. ( alist -- )
    [ [ subheader. ] [ items. ] bi* ] assoc-each nl ;

: sections>sequence ( alist -- alist )
    [ items>sequence ] assoc-map ;

: historical-url ( timestamp -- url )
    "wiki/%B_%d" strftime wikipedia-url ;

: historical-get ( timestamp -- xml )
    historical-url http-get nip string>xml ;

: historical-get-events ( timestamp -- alist )
    historical-get
    [ "h3" deep-tags-named 0 3 rot subseq [ deep-children>string ] map ]
    [ "ul" deep-tags-named 0 3 rot subseq ] bi zip ;

: historical-get-births ( timestamp -- alist )
    historical-get
    [ "h3" deep-tags-named 3 6 rot subseq [ deep-children>string ] map ]
    [ "ul" deep-tags-named 3 6 rot subseq ] bi zip ;

: historical-get-deaths ( timestamp -- alist )
    historical-get
    [ "h3" deep-tags-named 6 9 rot subseq [ deep-children>string ] map ]
    [ "ul" deep-tags-named 6 9 rot subseq ] bi zip ;

PRIVATE>

: historical-events ( timestamp -- events )
    historical-get-events sections>sequence ;

: historical-events. ( timestamp -- )
    [ "%B %d - Events" strftime header. ]
    [ historical-get-events sections. ] bi ;

: historical-births ( timestamp -- births )
    historical-get-births sections>sequence ;

: historical-births. ( timestamp -- )
    [ "%B %d - Births" strftime header. ]
    [ historical-get-births sections. ] bi ;

: historical-deaths ( timestamp -- births )
    historical-get-deaths sections>sequence ;

: historical-deaths. ( timestamp -- )
    [ "%B %d - Deaths" strftime header. ]
    [ historical-get-deaths sections. ] bi ;

: article. ( name -- )
    "wiki/" prepend wikipedia-url http-get nip parse-html
    "content" find-by-id-between
    html-text split-lines
    [ [ ascii:blank? ] trim ] map harvest [
        html-unescape 72 wrap-string print nl
    ] each ;

<PRIVATE

: eval-timestamp ( seq -- timestamp )
    [ today ] [
        " " join t auto-use? [ eval( -- timestamp ) ] with-variable
    ] if-empty ;

PRIVATE>

: wikipedia-main ( -- )
    command-line get [
        unclip {
            { "events" [ eval-timestamp historical-events. ] }
            { "births" [ eval-timestamp historical-births. ] }
            { "deaths" [ eval-timestamp historical-deaths. ] }
            { "article" [ [ article. ] each ] }
            [ "ERROR: Unknown command: " write print drop ]
        } case
    ] unless-empty ;

MAIN: wikipedia-main
