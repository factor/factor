! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs assocs.extras classes.tuple
colors.constants combinators formatting fry http.client io
io.styles json.reader kernel sequences urls wrap.strings ;

IN: google.search

<PRIVATE

: search-url ( query -- url )
    URL" http://ajax.googleapis.com/ajax/services/search/web" clone
        "1.0" "v" set-query-param
        swap "q" set-query-param
        "8" "rsz" set-query-param
        "0" "start" set-query-param ;

TUPLE: search-result cacheUrl GsearchResultClass visibleUrl
title content unescapedUrl url titleNoFormatting fileFormat ;

PRIVATE>

: google-search ( query -- results )
    search-url http-get nip json>
    { "responseData" "results" } deep-at
    [ \ search-result from-slots ] map ;

<PRIVATE

: write-heading ( str -- )
    H{
        { font-size 14 }
        { background COLOR: light-gray }
    } format nl ;

: write-title ( str -- )
    H{
        { foreground COLOR: blue }
    } format nl ;

: write-content ( str -- )
    60 wrap-string print ;

: write-url ( str -- )
    dup >url H{
        { font-name "monospace" }
        { foreground COLOR: dark-green }
    } [ write-object ] with-style nl ;

PRIVATE>

: google-search. ( query -- )
    [ "Search results for '%s'" sprintf write-heading nl ]
    [ google-search ] bi [
        {
            [ titleNoFormatting>> write-title ]
            [ content>> write-content ]
            [ unescapedUrl>> write-url ]
        } cleave nl
    ] each ;
