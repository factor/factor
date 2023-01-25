! Copyright (C) 2010-2012 Slava Pestov, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: assocs http.client json kernel namespaces sequences urls
;

IN: bitly

SYMBOLS: bitly-api-user bitly-api-key ;

<PRIVATE

: <bitly-url> ( path -- url )
    "https://api.bitly.com/v3/" prepend >url
        bitly-api-user get "login" set-query-param
        bitly-api-key get "apiKey" set-query-param
        "json" "format" set-query-param ;

ERROR: bad-response json status ;

: check-status ( json -- json )
    dup "status_code" of 200 = [
        dup "status_txt" of
        bad-response
    ] unless ;

: json-data ( url -- json )
    http-get nip json> check-status "data" of ;

: get-short-url ( short-url path -- data )
    <bitly-url> swap "shortUrl" set-query-param json-data ;

: get-long-url ( long-url path -- data )
    <bitly-url> swap "longUrl" set-query-param json-data ;

PRIVATE>

: shorten-url ( long-url -- short-url )
    "shorten" get-long-url "url" of ;

: expand-url ( short-url -- url )
    "expand" get-short-url "expand" of first "long_url" of ;

: valid-user? ( user api-key -- ? )
    "validate" <bitly-url>
        swap "x_apiKey" set-query-param
        swap "x_login" set-query-param
    json-data "valid" of 1 = ;

: clicks ( short-url -- clicks )
    "clicks" get-short-url "clicks" of first "global_clicks" of ;

: referrers ( short-url -- referrers )
    "referrers" get-short-url "referrers" of ;

: countries ( short-url -- countries )
    "countries" get-short-url "countries" of ;

: clicks-by-minute ( short-url -- clicks )
    "clicks_by_minute" get-short-url "clicks_by_minute" of ;

: clicks-by-day ( short-url -- clicks )
    "clicks_by_day" get-short-url "clicks_by_day" of ;

: lookup ( long-urls -- short-urls )
    "lookup" <bitly-url>
        swap "url" set-query-param
    json-data "lookup" of [ "short_url" of ] map ;

: info ( short-url -- title )
    "info" get-short-url "info" of first "title" of ;
