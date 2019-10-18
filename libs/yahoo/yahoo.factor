! Copyright (C) 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: http-client xml xml-utils kernel sequences namespaces http errors help ;
IN: yahoo

TUPLE: result title url summary ;

: parse-yahoo ( xml -- seq )
    "Result" tags-named* [
        { "Title" "Url" "Summary" }
        [ tag-named children>string ] map-with
        first3 <result>
    ] map ;

: yahoo-url ( -- str )
    "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=Factor-search&query=" ;

: query ( search num -- url )
    [
        yahoo-url %
        swap url-encode %
        "&results=" % #
    ] "" make ;

: search-yahoo ( search num -- seq )
    query http-get 2nip
    [ "Search failed" throw ] unless*
    string>xml parse-yahoo ;
