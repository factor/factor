! Copyright (C) 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: http.client xml xml.utilities kernel sequences
namespaces http math.parser help math.order locals ;
IN: yahoo

TUPLE: result title url summary ;

C: <result> result

: parse-yahoo ( xml -- seq )
    "Result" deep-tags-named [
        { "Title" "Url" "Summary" }
        [ tag-named children>string ] with map
        first3 <result>
    ] map ;

: yahoo-url ( -- str )
    "http://search.yahooapis.com/WebSearchService/V1/webSearch" ;

:: query ( search num appid -- url )
    [
        yahoo-url %
        "?appid=" % appid %
        "&query=" % search url-encode %
        "&results=" % num #
    ] "" make ;

: factor-id
    "fRrVAKzV34GDyeRw6bUHDhEWHRedwfOC7e61wwXZLgGF80E67spxdQXuugBe2pgIevMmKwA-" ;

: search-yahoo/id ( search num id -- seq )
    query http-get string>xml parse-yahoo ;

: search-yahoo ( search num -- seq )
    factor-id search-yahoo/id ;
