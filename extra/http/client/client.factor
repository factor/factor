! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http kernel math math.parser namespaces sequences
io io.sockets io.streams.string io.files io.timeouts strings
splitting calendar continuations accessors vectors io.encodings.latin1
io.encodings.binary ;
IN: http.client

: parse-url ( url -- resource host port )
    "http://" ?head [ "Only http:// supported" throw ] unless
    "/" split1 [ "/" swap append ] [ "/" ] if*
    swap parse-host ;

<PRIVATE

: store-path ( request path -- request )
    "?" split1 >r >>path r> dup [ query>assoc ] when >>query ;

! This is all pretty complex because it needs to handle
! HTTP redirects, which might be absolute or relative
: request-with-url ( url request -- request )
    clone dup "request" set
    swap parse-url >r >r store-path r> >>host r> >>port ;

DEFER: (http-request)

: absolute-redirect ( url -- request )
    "request" get request-with-url ;

: relative-redirect ( path -- request )
    "request" get swap store-path ;

: do-redirect ( response -- response stream )
    dup response-code 300 399 between? [
        header>> "location" swap at
        dup "http://" head? [
            absolute-redirect
        ] [
            relative-redirect
        ] if "GET" >>method (http-request)
    ] [
        stdio get
    ] if ;

: (http-request) ( request -- response stream )
    dup host>> over port>> <inet> latin1 <client> stdio set
    dup "r" set-global  write-request flush read-response
    do-redirect ;

PRIVATE>

: http-request ( url request -- response stream )
    [
        request-with-url
        [
            (http-request)
            1 minutes over set-timeout
        ] [ ] [ stdio get dispose ] cleanup
    ] with-scope ;

: <get-request> ( -- request )
    <request> "GET" >>method ;

: http-get-stream ( url -- response stream )
    <get-request> http-request ;

: success? ( code -- ? ) 200 = ;

: check-response ( response stream -- stream )
    swap code>> success?
    [ dispose "HTTP download failed" throw ] unless ;

: http-get ( url -- string )
    http-get-stream check-response contents ;

: download-name ( url -- name )
    file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    #! Downloads the contents of a URL to a file.
    swap http-get-stream check-response
    [ swap binary <file-writer> stream-copy ] with-disposal ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( content-type content -- request )
    <request>
    "POST" >>method
    swap >>post-data
    swap >>post-data-type ;

: http-post ( content-type content url -- response string )
    #! The content is URL encoded for you.
    -rot url-encode <post-request> http-request contents ;
