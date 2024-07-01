! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs calendar combinators
combinators.short-circuit continuations destructors effects
environment hashtables http http.client.post-data http.parsers
http.websockets io io.crlf io.encodings io.encodings.ascii
io.encodings.binary io.encodings.iana io.encodings.string
io.files io.files.info io.pathnames io.sockets io.sockets.secure
io.timeouts kernel math math.order math.parser mime.types
namespaces present protocols sequences splitting urls
vocabs.loader ;
IN: http.client

ERROR: too-many-redirects ;
ERROR: invalid-proxy proxy ;

: success? ( code -- ? ) 200 299 between? ;

ERROR: download-failed response ;

: check-response ( response -- response )
    dup code>> success? [ download-failed ] unless ;

<PRIVATE

: authority-uri ( url -- str )
    [ host>> ] [ port>> number>string ] bi ":" glue ;

: absolute-uri ( url -- str )
    clone f >>username f >>password f >>anchor present ;

: abs-path-uri ( url -- str )
    relative-url f >>anchor present ;

: request-uri ( request -- str )
    {
        { [ dup proxy-url>> ] [ url>> absolute-uri ] }
        { [ dup method>> "CONNECT" = ] [ url>> authority-uri ] }
        [ url>> abs-path-uri ]
    } cond ;

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ request-uri write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

: default-port? ( url -- ? )
    {
        [ port>> not ]
        [ [ port>> ] [ protocol>> lookup-protocol-port ] bi = ]
    } 1|| ;

: unparse-host ( url -- string )
    dup default-port? [ host>> ] [
        [ host>> ] [ port>> number>string ] bi ":" glue
    ] if ;

: set-host-header ( request header -- request header )
    over url>> unparse-host "Host" pick set-at ;

: set-cookie-header ( header cookies -- header )
    unparse-cookie "Cookie" pick set-at ;

: ?set-basic-auth ( header url name -- header )
    swap [
        [ username>> ] [ password>> ] bi 2dup and
        [ basic-auth swap pick set-at ] [ 3drop ] if
    ] [ drop ] if* ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ set-host-header ] when
    over url>> "Authorization" ?set-basic-auth
    over proxy-url>> "Proxy-Authorization" ?set-basic-auth
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

SYMBOL: redirects

: redirect-url ( request url -- request )
    '[ _ >url derive-url ensure-port ] change-url ;

: redirect? ( response -- ? )
    code>> 300 399 between? ;

:: prepare-redirect ( response -- response )
    redirects inc
    redirects get request get redirects>> < [
        request get clone
        response "location" header redirect-url
        response code>> 307 = [ "GET" >>method f >>post-data ] unless
    ] [ too-many-redirects ] if ; inline recursive

: read-chunk-size ( -- n )
    read-crlf ";" split1 drop [ blank? ] trim-tail
    hex> [ "Bad chunk size" throw ] unless* ;

: read-chunked ( quot: ( chunk -- ) -- )
    read-chunk-size [ drop ] [
        read [ swap call ] [ drop ] 2bi
        read-crlf B{ } assert= read-chunked
    ] if-zero ; inline recursive

: read-response-body ( quot: ( chunk -- ) response -- )
    binary decode-input
    "transfer-encoding" header "chunked" =
    [ read-chunked ] [ each-block ] if ; inline

: request-socket-endpoints ( request -- physical logical )
    [ proxy-url>> ] [ url>> ] bi [ or ] keep ;

: <request-socket> ( -- stream )
    request get request-socket-endpoints [ url-addr ] bi@
    remote-address set ascii <client> local-address set
    1 minutes over set-timeout ;

: https-tunnel? ( request -- ? )
    [ proxy-url>> ] [ url>> protocol>> "https" = ] bi and ;

: ?copy-proxy-basic-auth ( dst-request src-request -- dst-request )
    proxy-url>> [ username>> ] [ password>> ] bi 2dup and
    [ set-proxy-basic-auth ] [ 2drop ] if ;

: ?https-tunnel ( -- )
    request get dup https-tunnel? [
        <request> swap [ url>> >>url ] [ ?copy-proxy-basic-auth ] bi
        f >>proxy-url "CONNECT" >>method write-request
        read-response check-response drop send-secure-handshake
    ] [ drop ] if ;

! Note: ipv4 addresses are interpreted as subdomains but "work"
: no-proxy-match? ( host-path no-proxy-path -- ? )
    dup first empty? [ [ rest ] bi@ ] when
    [ drop f ] [ tail? ] if-empty ;

: get-no-proxy-list ( -- list )
    "no_proxy" get
    [ "no_proxy" os-env ] unless*
    [ "NO_PROXY" os-env ] unless* ;

: no-proxy? ( request -- ? )
    get-no-proxy-list [
        [ url>> host>> "." split ] dip "," split
        [ "." split no-proxy-match? ] with any?
    ] [ drop f ] if* ;

: (check-proxy) ( proxy -- ? )
    {
        { [ dup URL" " = ] [ drop f ] }
        { [ dup host>> ] [ drop t ] }
        [ invalid-proxy ]
    } cond ;

: check-proxy ( request proxy -- request' )
    dup [ (check-proxy) ] [ f ] if*
    and* [ clone ] dip >>proxy-url ;

: get-default-proxy ( request -- default-proxy )
    url>> protocol>> "https" = [
        "https.proxy" get
        [ "https_proxy" os-env ] unless*
        [ "HTTPS_PROXY" os-env ] unless*
    ] [
        "http.proxy" get
        [ "http_proxy" os-env ] unless*
        [ "HTTP_PROXY" os-env ] unless*
    ] if ;

: misparsed-url? ( url -- url' )
    { [ protocol>> not ] [ host>> not ] [ path>> ] } 1&& ;

: request-url ( url -- url' )
    dup >url dup misparsed-url? [
        drop dup url? [ present ] when
        "http://" prepend >url
    ] [ nip ] if ensure-port ;

: ?default-proxy ( request -- request' )
    dup get-default-proxy
    over proxy-url>> dup [ request-url ] when 2dup and [
        pick no-proxy? [ nip ] [ [ request-url ] dip derive-url ] if
    ] [ nip ] if check-proxy ;

: upgrade-to-websocket? ( response -- ? )
    {
        [ response? ]
        [ code>> 101 = ]
        [ message>> >lower "switching protocols" = ]
        [ header>> "connection" of "upgrade" = ]
        [ header>> "upgrade" of "websocket" = ]
    } 1&& ;

PRIVATE>

SYMBOL: request-socket

: do-http-request ( request quot: ( chunk -- ) -- response/stream )
    [ ?default-proxy \ request ] dip dup '[
        [
            <request-socket> |dispose
            dup request-socket set
            [
                [ in>> ] [ out>> ] bi [ ?https-tunnel ] with-streams*
            ]
            [
                out>>
                [ request get write-request ]
                with-output-stream*
            ]
            [
                in>> [
                    read-response
                    dup redirect?
                    request get redirects>> 0 > and [
                        request-socket get dispose
                        prepare-redirect _ do-http-request
                    ] [
                        dup upgrade-to-websocket?
                        [ drop request-socket get ]
                        [
                            [ _ ] dip [ read-response-body ] keep
                            request-socket get dispose
                        ] if
                    ] if
                ] with-input-stream*
            ] tri
        ] with-destructors
    ] with-variable ; inline recursive

: add-default-headers ( request -- request )
    dup url>> protocol>> {
        { [ dup { "ws" "wss" } member? ] [ drop add-websocket-upgrade-headers ] }
        [ drop ]
    } cond ;

: <client-request> ( url method -- request )
    <request>
        swap >>method
        swap request-url >>url
        add-default-headers ; inline

: with-http-request ( request quot: ( chunk -- ) -- response/stream )
    do-http-request check-response ; inline

: http-request* ( request -- response data )
    BV{ } clone [ '[ _ push-all ] do-http-request ] keep
    B{ } like over content-encoding>> decode [ >>body ] keep ;

: http-request ( request -- response data )
    http-request* [ check-response ] dip ;

: <get-request> ( url -- request )
    "GET" <client-request> ;

: http-get ( url -- response data )
    <get-request> http-request ;

: http-get* ( url -- response data )
    <get-request> http-request* ;

: <post-request> ( post-data url -- request )
    "POST" <client-request>
        swap >>post-data ;

: http-post ( post-data url -- response data )
    <post-request> http-request ;

: http-post* ( post-data url -- response data )
    <post-request> http-request* ;

: <put-request> ( post-data url -- request )
    "PUT" <client-request>
        swap >>post-data ;

: http-put ( post-data url -- response data )
    <put-request> http-request ;

: http-put* ( post-data url -- response data )
    <put-request> http-request* ;

: <delete-request> ( url -- request )
    "DELETE" <client-request> ;

: http-delete ( url -- response data )
    <delete-request> http-request ;

: http-delete* ( url -- response data )
    <delete-request> http-request* ;

: <head-request> ( url -- request )
    "HEAD" <client-request> ;

: http-head ( url -- response data )
    <head-request> http-request ;

: http-head* ( url -- response data )
    <head-request> http-request* ;

: <options-request> ( url -- request )
    "OPTIONS" <client-request> ;

: http-options ( url -- response data )
    <options-request> http-request ;

: http-options* ( url -- response data )
    <options-request> http-request* ;

: <patch-request> ( patch-data url -- request )
    "PATCH" <client-request>
        swap >>post-data ;

: http-patch ( patch-data url -- response data )
    <patch-request> http-request ;

: http-patch* ( patch-data url -- response data )
    <patch-request> http-request* ;

: <trace-request> ( url -- request )
    "TRACE" <client-request> ;

: http-trace ( url -- response data )
    <trace-request> http-request ;

: http-trace* ( url -- response data )
    <trace-request> http-request* ;

{ "http.client" "debugger" } "http.client.debugger" require-when
