! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http kernel math math.parser namespaces sequences
io io.sockets io.streams.string io.files io.timeouts strings
splitting calendar continuations accessors vectors math.order
io.encodings.8-bit io.encodings.binary io.streams.duplex
fry debugger inspector ;
IN: http.client

: max-redirects 10 ;

ERROR: too-many-redirects ;

M: too-many-redirects summary
    drop
    [ "Redirection limit of " % max-redirects # " exceeded" % ] "" make ;

DEFER: http-request

<PRIVATE

: parse-url ( url -- resource host port )
    "http://" ?head [ "Only http:// supported" throw ] unless
    "/" split1 [ "/" prepend ] [ "/" ] if*
    swap parse-host ;

: store-path ( request path -- request )
    "?" split1 >r >>path r> dup [ query>assoc ] when >>query ;

: request-with-url ( url request -- request )
    swap parse-url >r >r store-path r> >>host r> >>port ;

! This is all pretty complex because it needs to handle
! HTTP redirects, which might be absolute or relative
: absolute-redirect ( url -- request )
    request get request-with-url ;

: relative-redirect ( path -- request )
    request get swap store-path ;

SYMBOL: redirects

: absolute-url? ( url -- ? )
    [ "http://" head? ] [ "https://" head? ] bi or ;

: do-redirect ( response -- response stream )
    dup response-code 300 399 between? [
        output-stream get dispose
        redirects inc
        redirects get max-redirects < [
            header>> "location" swap at
            dup absolute-url? [
                absolute-redirect
            ] [
                relative-redirect
            ] if "GET" >>method http-request
        ] [
            too-many-redirects
        ] if
    ] [
        output-stream get
    ] if ;

: close-on-error ( stream quot -- )
    '[ , with-stream* ] [ ] pick '[ , dispose ] cleanup ; inline

PRIVATE>

: http-request ( request -- response stream )
    dup request [
        dup request-addr latin1 <client>
        [
            1 minutes timeouts
            write-request
            input-stream get dispose
            read-response
            do-redirect
        ] close-on-error
    ] with-variable ;

: read-chunks ( -- )
    read-crlf ";" split1 drop hex> dup { f 0 } member?
    [ drop ] [ read % read-crlf "" assert= read-chunks ] if ;

: do-chunked-encoding ( response stream -- response stream/string )
    over "transfer-encoding" header "chunked" = [
        [ [ read-chunks ] "" make ] with-input-stream
    ] when ;

: <get-request> ( url -- request )
    <request> request-with-url "GET" >>method ;

: string-or-contents ( stream/string -- string )
    dup string? [ contents ] unless ;

: http-get-stream ( url -- response stream/string )
    <get-request> http-request do-chunked-encoding ;

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
    http-get-stream string-or-contents check-response ;

: download-name ( url -- name )
    file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    #! Downloads the contents of a URL to a file.
    swap http-get-stream check-response
    dup string? [
        latin1 [ write ] with-file-writer
    ] [
        [ swap latin1 <file-writer> stream-copy ] with-disposal
    ] if ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( content-type content url -- request )
    <request>
    request-with-url
    "POST" >>method
    swap >>post-data
    swap >>post-data-type ;

: http-post ( content-type content url -- response string )
    <post-request> http-request do-chunked-encoding string-or-contents ;
