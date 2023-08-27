! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors http http.client http.client.private kernel
math namespaces ;

IN: long-urls

SYMBOL: max-redirects
5 max-redirects set-global

<PRIVATE

SYMBOL: redirects

: http-head-no-redirects ( url -- response data )
    <head-request> 0 >>redirects http-request* ;

: next-url ( url -- next-url redirected? )
    redirects inc
    redirects get max-redirects get <= [
        dup http-head-no-redirects drop
        dup redirect? [
            nip "location" header t
        ] [ drop f ] if
    ] [ too-many-redirects ] if ;

PRIVATE>

: long-url ( short-url -- long-url )
    [ [ next-url ] loop ] with-scope ;
