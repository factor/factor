! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math math.parser namespaces make
sequences strings splitting calendar continuations accessors vectors
math.order hashtables byte-arrays destructors
io io.sockets io.streams.string io.files io.timeouts
io.pathnames io.encodings io.encodings.string io.encodings.ascii
io.encodings.utf8 io.encodings.8-bit io.encodings.binary io.crlf
io.streams.duplex fry ascii urls urls.encoding present locals
http http.parsers http.client.post-data ;
IN: http.client

ERROR: too-many-redirects ;

CONSTANT: max-redirects 10

<PRIVATE

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ url>> relative-url present write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

: url-host ( url -- string )
    [ host>> ] [ port>> ] bi dup "http" protocol-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: set-host-header ( request header -- request header )
    over url>> url-host "host" pick set-at ;

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
    read-crlf parse-response-line first3
    [ >>version ] [ >>code ] [ >>message ] tri* ;

: read-response-header ( response -- response )
    read-header >>header
    dup "set-cookie" header parse-set-cookie >>cookies
    dup "content-type" header [
        parse-content-type
        [ >>content-type ]
        [ >>content-charset ] bi*
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
    redirects get max-redirects < [
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
                    read-response dup redirect? [ t ] [
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

: <client-request> ( url method -- request )
    <request>
        swap >>method
        swap >url ensure-port >>url ; inline

PRIVATE>

: success? ( code -- ? ) 200 299 between? ;

ERROR: download-failed response ;

: check-response ( response -- response )
    dup code>> success? [ download-failed ] unless ;

: check-response-with-body ( response body -- response body )
    [ >>body check-response ] keep ;

: with-http-request ( request quot -- response )
    [ (with-http-request) ] with-destructors ; inline

: http-request ( request -- response data )
    [ [ % ] with-http-request ] B{ } make
    over content-charset>> decode check-response-with-body ;

: <get-request> ( url -- request )
    "GET" <client-request> ;

: http-get ( url -- response data )
    <get-request> http-request ;

: with-http-get ( url quot -- response )
    [ <get-request> ] dip with-http-request ; inline

: download-name ( url -- name )
    present file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    binary [ [ write ] with-http-get check-response drop ] with-file-writer ;

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

USING: vocabs vocabs.loader ;

"debugger" vocab [ "http.client.debugger" require ] when
