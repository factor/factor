! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs calendar combinators.short-circuit
destructors fry hashtables http http.client.post-data
http.parsers io io.crlf io.encodings io.encodings.ascii
io.encodings.binary io.encodings.iana io.encodings.string
io.files io.pathnames io.sockets io.timeouts kernel locals math
math.order math.parser mime.types namespaces present sequences
splitting urls vocabs.loader ;
IN: http.client

ERROR: too-many-redirects ;

<PRIVATE

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ url>> relative-url present write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

: default-port? ( url -- ? )
    {
        [ port>> not ]
        [ [ port>> ] [ protocol>> protocol-port ] bi = ]
    } 1|| ;

: unparse-host ( url -- string )
    dup default-port? [ host>> ] [
        [ host>> ] [ port>> number>string ] bi ":" glue
    ] if ;

: set-host-header ( request header -- request header )
    over url>> unparse-host "host" pick set-at ;

: set-cookie-header ( header cookies -- header )
    unparse-cookie "cookie" pick set-at ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ set-host-header ] when
    over post-data>> [ set-post-data-headers ] when*
    over cookies>> [ set-cookie-header ] unless-empty
    write-header ;

: write-request ( request -- )
    unparse-post-data
    write-request-line
    write-request-header
    binary encode-output
    write-post-data
    flush
    drop ;

: read-response-line ( response -- response )
    read-?crlf parse-response-line first3
    [ >>version ] [ >>code ] [ >>message ] tri* ;

: detect-encoding ( response -- encoding )
    [ content-charset>> name>encoding ]
    [ content-type>> mime-type-encoding ] bi
    or ;

: read-response-header ( response -- response )
    read-header >>header
    dup "set-cookie" header parse-set-cookie >>cookies
    dup "content-type" header [
        parse-content-type
        [ >>content-type ] [ >>content-charset ] bi*
        dup detect-encoding >>content-encoding
    ] when* ;

: read-response ( -- response )
    <response>
    read-response-line
    read-response-header ;

DEFER: (with-http-request)

SYMBOL: redirects

: redirect-url ( request url -- request )
    '[ _ >url derive-url ensure-port ] change-url ;

: redirect? ( response -- ? )
    code>> 300 399 between? ;

:: do-redirect ( quot: ( chunk -- ) response -- response )
    redirects inc
    redirects get request get redirects>> < [
        request get clone
        response "location" header redirect-url
        response code>> 307 = [ "GET" >>method ] unless
        quot (with-http-request)
    ] [ too-many-redirects ] if ; inline recursive

: read-chunk-size ( -- n )
    read-crlf ";" split1 drop [ blank? ] trim-tail
    hex> [ "Bad chunk size" throw ] unless* ;

: read-chunked ( quot: ( chunk -- ) -- )
    read-chunk-size dup zero?
    [ 2drop ] [
        read [ swap call ] [ drop ] 2bi
        read-crlf B{ } assert= read-chunked
    ] if ; inline recursive

: read-response-body ( quot response -- )
    binary decode-input
    "transfer-encoding" header "chunked" =
    [ read-chunked ] [ each-block ] if ; inline

: <request-socket> ( -- stream )
    request get url>> url-addr ascii <client> drop
    1 minutes over set-timeout ;

: (with-http-request) ( request quot: ( chunk -- ) -- response )
    swap
    request [
        <request-socket> [
            [
                out>>
                [ request get write-request ]
                with-output-stream*
            ] [
                in>> [
                    read-response dup redirect?
                    request get redirects>> 0 > and [ t ] [
                        [ nip response set ]
                        [ read-response-body ]
                        [ ]
                        2tri f
                    ] if
                ] with-input-stream*
            ] bi
        ] with-disposal
        [ do-redirect ] [ nip ] if
    ] with-variable ; inline recursive

: request-url ( url -- url' )
    dup >url dup protocol>> [ nip ] [
        drop dup url? [ present ] when
        "http://" prepend >url
    ] if ensure-port ;

: <client-request> ( url method -- request )
    <request>
        swap >>method
        swap request-url >>url ; inline

PRIVATE>

: success? ( code -- ? ) 200 299 between? ;

ERROR: download-failed response ;

: check-response ( response -- response )
    dup code>> success? [ download-failed ] unless ;

: with-http-request* ( request quot: ( chunk -- ) -- response )
    [ (with-http-request) ] with-destructors ; inline

: with-http-request ( request quot: ( chunk -- ) -- response )
    with-http-request* check-response ; inline

: http-request* ( request -- response data )
    BV{ } clone [ '[ _ push-all ] with-http-request* ] keep
    B{ } like over content-encoding>> decode [ >>body ] keep ;

: http-request ( request -- response data )
    http-request* [ check-response ] dip ;

: <get-request> ( url -- request )
    "GET" <client-request> ;

: http-get ( url -- response data )
    <get-request> http-request ;

: download-name ( url -- name )
    present file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    binary [
        <get-request> [ write ] with-http-request drop
    ] with-file-writer ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( post-data url -- request )
    "POST" <client-request>
        swap >>post-data ;

: http-post ( post-data url -- response data )
    <post-request> http-request ;

: <put-request> ( post-data url -- request )
    "PUT" <client-request>
        swap >>post-data ;

: http-put ( post-data url -- response data )
    <put-request> http-request ;

: <delete-request> ( url -- request )
    "DELETE" <client-request> ;

: http-delete ( url -- response data )
    <delete-request> http-request ;

: <head-request> ( url -- request )
    "HEAD" <client-request> ;

: http-head ( url -- response data )
    <head-request> http-request ;

: <options-request> ( url -- request )
    "OPTIONS" <client-request> ;

: http-options ( url -- response data )
    <options-request> http-request ;

: <trace-request> ( url -- request )
    "TRACE" <client-request> ;

: http-trace ( url -- response data )
    <trace-request> http-request ;

USE: vocabs.loader

{ "http.client" "debugger" } "http.client.debugger" require-when
