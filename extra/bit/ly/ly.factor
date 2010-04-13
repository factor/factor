! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http.client json.reader kernel namespaces urls ;
IN: bit.ly

SYMBOLS: login api-key ;

<PRIVATE

: make-request ( long-url -- request )
    "http://api.bit.ly/v3/shorten" >url
        login get "login" set-query-param
        api-key get "apiKey" set-query-param
        "json" "format" set-query-param
        swap "longUrl" set-query-param ;

: parse-response ( response data -- short-url )
    nip json> "data" swap at "url" swap at ;

PRIVATE>

: shorten-url ( long-url -- short-url )
    make-request http-get parse-response ;
