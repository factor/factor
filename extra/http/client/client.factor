! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http kernel math math.parser namespaces sequences
io io.sockets io.streams.string io.files io.timeouts strings
splitting calendar continuations accessors vectors
io.encodings.8-bit io.encodings.binary fry ;
IN: http.client

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

: do-redirect ( response -- response stream )
    dup response-code 300 399 between? [
        stdio get dispose
        header>> "location" swap at
        dup "http://" head? [
            absolute-redirect
        ] [
            relative-redirect
        ] if "GET" >>method http-request
    ] [
        stdio get
    ] if ;

: request-addr ( request -- addr )
    dup host>> swap port>> <inet> ;

: close-on-error ( stream quot -- )
    '[ , with-stream* ] [ ] pick '[ , dispose ] cleanup ; inline

PRIVATE>

: http-request ( request -- response stream )
    dup request [
        dup request-addr latin1 <client>
        1 minutes over set-timeout
        [
            write-request flush
            read-response
            do-redirect
        ] close-on-error
    ] with-variable ;

: <get-request> ( url -- request )
    <request> request-with-url "GET" >>method ;

: http-get-stream ( url -- response stream )
    <get-request> http-request ;

: success? ( code -- ? ) 200 = ;

: check-response ( response -- )
    code>> success?
    [ "HTTP download failed" throw ] unless ;

: http-get ( url -- string )
    http-get-stream contents swap check-response ;

: download-name ( url -- name )
    file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    #! Downloads the contents of a URL to a file.
    swap http-get-stream swap check-response
    [ swap latin1 <file-writer> stream-copy ] with-disposal ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( content-type content url -- request )
    <request>
    request-with-url
    "POST" >>method
    swap >>post-data
    swap >>post-data-type ;

: http-post ( content-type content url -- response string )
    <post-request> http-request contents ;
