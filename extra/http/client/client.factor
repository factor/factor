! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http kernel math math.parser namespaces sequences
io io.sockets io.streams.string io.files io.timeouts strings
splitting calendar continuations accessors vectors math.order
io.encodings.8-bit io.encodings.binary io.streams.duplex
fry debugger inspector ascii ;
IN: http.client

: max-redirects 10 ;

ERROR: too-many-redirects ;

M: too-many-redirects summary
    drop
    [ "Redirection limit of " % max-redirects # " exceeded" % ] "" make ;

DEFER: http-request

<PRIVATE

SYMBOL: redirects

: do-redirect ( response data -- response data )
    over code>> 300 399 between? [
        drop
        redirects inc
        redirects get max-redirects < [
            request get
            swap "location" header request-with-url
            "GET" >>method http-request
        ] [
            too-many-redirects
        ] if
    ] when ;

PRIVATE>

: read-chunk-size ( -- n )
    read-crlf ";" split1 drop [ blank? ] right-trim
    hex> [ "Bad chunk size" throw ] unless* ;

: read-chunks ( -- )
    read-chunk-size dup zero?
    [ drop ] [ read % read-crlf "" assert= read-chunks ] if ;

: read-response-body ( response -- response data )
    dup "transfer-encoding" header "chunked" =
    [ [ read-chunks ] "" make ] [ input-stream get contents ] if ;

: http-request ( request -- response data )
    dup request [
        dup url>> url-addr latin1 [
            1 minutes timeouts
            write-request
            read-response
            read-response-body
        ] with-client
        do-redirect
    ] with-variable ;

: <get-request> ( url -- request )
    <request>
        swap request-with-url
        "GET" >>method ;

: http-get* ( url -- response data )
    <get-request> http-request ;

: success? ( code -- ? ) 200 = ;

ERROR: download-failed response body ;

M: download-failed error.
    "HTTP download failed:" print nl
    [
        response>>
            write-response-code
            write-response-message nl
        drop
    ]
    [ body>> write ] bi ;

: check-response ( response string -- string )
    over code>> success? [ nip ] [ download-failed ] if ;

: http-get ( url -- string )
    http-get* check-response ;

: download-name ( url -- name )
    file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    #! Downloads the contents of a URL to a file.
    [ http-get ] dip latin1 [ write ] with-file-writer ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( content-type content url -- request )
    <request>
        "POST" >>method
        swap request-with-url
        swap >>post-data
        swap >>post-data-type ;

: http-post ( content-type content url -- response data )
    <post-request> http-request ;
