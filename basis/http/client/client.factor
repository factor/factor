! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math math.parser namespaces make
sequences strings splitting calendar continuations accessors vectors
math.order hashtables byte-arrays destructors
io io.sockets io.streams.string io.files io.timeouts
io.pathnames io.encodings io.encodings.string io.encodings.ascii
io.encodings.utf8 io.encodings.8-bit io.encodings.binary
io.streams.duplex fry ascii urls urls.encoding present
http http.parsers ;
IN: http.client

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ url>> relative-url present write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

: url-host ( url -- string )
    [ host>> ] [ port>> ] bi dup "http" protocol-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ over url>> url-host "host" pick set-at ] when
    over post-data>> [
        [ data>> length "content-length" pick set-at ]
        [ content-type>> "content-type" pick set-at ]
        bi
    ] when*
    over cookies>> [ unparse-cookie "cookie" pick set-at ] unless-empty
    write-header ;

GENERIC: >post-data ( object -- post-data )

M: f >post-data ;

M: post-data >post-data ;

M: string >post-data
    utf8 encode
    "application/octet-stream" <post-data>
        swap >>data ;

M: assoc >post-data
    "application/x-www-form-urlencoded" <post-data>
        swap >>params ;

M: object >post-data
    "application/octet-stream" <post-data>
        swap >>data ;

: normalize-post-data ( request -- request )
    dup post-data>> [
        dup params>> [
            assoc>query ascii encode >>data
        ] when* drop
    ] when* ;

: unparse-post-data ( request -- request )
    [ >post-data ] change-post-data
    normalize-post-data ;

: write-post-data ( request -- request )
    dup method>> { "POST" "PUT" } member?  [
        dup post-data>> data>> dup sequence?
        [ write ] [ output-stream get stream-copy ] if
    ] when ; 

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

: max-redirects 10 ;

ERROR: too-many-redirects ;

<PRIVATE

DEFER: (with-http-request)

SYMBOL: redirects

: redirect-url ( request url -- request )
    '[ _ >url derive-url ensure-port ] change-url ;

: redirect? ( response -- ? )
    code>> 300 399 between? ;

: do-redirect ( quot: ( chunk -- ) response -- response )
    redirects inc
    redirects get max-redirects < [
        request get clone
        swap "location" header redirect-url
        "GET" >>method swap (with-http-request)
    ] [ too-many-redirects ] if ; inline recursive

: read-chunk-size ( -- n )
    read-crlf ";" split1 drop [ blank? ] trim-right
    hex> [ "Bad chunk size" throw ] unless* ;

: read-chunked ( quot: ( chunk -- ) -- )
    read-chunk-size dup zero?
    [ 2drop ] [
        read [ swap call ] [ drop ] 2bi
        read-crlf B{ } assert= read-chunked
    ] if ; inline recursive

: read-unchunked ( quot: ( chunk -- ) -- )
    8192 read-partial dup [
        [ swap call ] [ drop read-unchunked ] 2bi
    ] [ 2drop ] if ; inline recursive

: read-response-body ( quot response -- )
    binary decode-input
    "transfer-encoding" header "chunked" =
    [ read-chunked ] [ read-unchunked ] if ; inline

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

PRIVATE>

: success? ( code -- ? ) 200 299 between? ;

ERROR: download-failed response ;

: check-response ( response -- response )
    dup code>> success? [ download-failed ] unless ;

: with-http-request ( request quot -- response )
    (with-http-request) check-response ; inline

: http-request ( request -- response data )
    [ [ % ] with-http-request ] B{ } make
    over content-charset>> decode ;

: <get-request> ( url -- request )
    <request>
        "GET" >>method
        swap >url ensure-port >>url ;

: http-get ( url -- response data )
    <get-request> http-request ;

: with-http-get ( url quot -- response )
    [ <get-request> ] dip with-http-request ; inline

: download-name ( url -- name )
    present file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    binary [ [ write ] with-http-get drop ] with-file-writer ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( post-data url -- request )
    <request>
        "POST" >>method
        swap >url ensure-port >>url
        swap >>post-data ;

: http-post ( post-data url -- response data )
    <post-request> http-request ;

USING: vocabs vocabs.loader ;

"debugger" vocab [ "http.client.debugger" require ] when
