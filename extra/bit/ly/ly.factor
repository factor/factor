! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http.client json.reader kernel namespaces urls ;
IN: bit.ly

SYMBOLS: login api-key ;

<PRIVATE

: of ( assoc key -- value ) swap at ;

: make-request ( long-url -- request )
    "http://api.bit.ly/v3/shorten" >url
        login get "login" set-query-param
        api-key get "apiKey" set-query-param
        "json" "format" set-query-param
        swap "longUrl" set-query-param ;

ERROR: bad-response json status ;

: check-response ( json -- json )
    dup "status_code" of 200 = [
        dup "status_txt" of
        bad-response
    ] unless ;

: parse-response ( response data -- short-url )
    nip json> check-response "data" of "url" of ;

PRIVATE>

: shorten-url ( long-url -- short-url )
    make-request http-get parse-response ;
