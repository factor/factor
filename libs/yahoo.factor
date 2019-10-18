REQUIRES: libs/http-client libs/xml libs/httpd ;
USING: http-client xml xml-utils kernel sequences namespaces http errors help ;
IN: yahoo

: parse-yahoo ( xml -- seq )
    "Result" get-name-tags [
        { "Title" "Url" "Summary" }
        [ get-tag children>string ] map-with
    ] map ;

: yahoo-url ( -- str )
    "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=Factor&query=" ;

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

HELP: search-yahoo
{ $values { "search" "a string" } { "num" "a positive integer" } { "seq" "sequence of arrays of length 3" } }
{ $description "Uses Yahoo's REST API to search for the query specified in the search string, getting the number of answers specified. Returns a sequence of 3arrays, { title url summary }, each of which is a string." } ;

PROVIDE: yahoo ;
