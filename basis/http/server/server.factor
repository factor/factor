! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit continuations debugger destructors
hashtables html html.streams html.templates http
http.server.remapping http.server.requests http.server.responses
io io.crlf io.encodings io.encodings.ascii io.encodings.iana
io.encodings.utf8 io.servers io.sockets io.sockets.secure
io.streams.limited kernel logging logging.insomniac math
mime.types namespaces present protocols sequences splitting
tools.time urls vectors vocabs vocabs.refresh xml.writer ;
IN: http.server

GENERIC: write-response ( response -- )

GENERIC: write-full-response ( request response -- )

: write-response-line ( response -- response )
    dup
    [ "HTTP/" write version>> write bl ]
    [ code>> present write bl ]
    [ message>> write crlf ]
    tri ;

: unparse-content-type ( request -- content-type )
    [ content-type>> ] [ content-charset>> ] bi
    over mime-type-encoding encoding>name or
    [ "application/octet-stream" or ] dip
    [ "; charset=" glue ] when* ;

: ensure-domain ( cookie -- cookie )
    [
        url get host>> dup "localhost" =
        [ drop ] [ or ] if
    ] change-domain ;

: write-response-header ( response -- response )
    ! We send one set-cookie header per cookie, because that's
    ! what Firefox expects.
    dup header>> >alist >vector
    over unparse-content-type "content-type" pick set-at
    over cookies>> [
        ensure-domain unparse-set-cookie
        "set-cookie" swap 2array suffix!
    ] each
    write-header ;

: write-response-body ( response -- response )
    dup body>> call-template ;

M: response write-response
    write-response-line
    write-response-header
    flush
    drop ;

M: response write-full-response
    dup write-response
    swap method>> "HEAD" = [
        [ content-encoding>> encode-output ]
        [ write-response-body ]
        bi
    ] unless drop ;

M: raw-response write-response
    write-response-line
    write-response-body
    drop ;

M: raw-response write-full-response
    nip write-response ;

: method= ( str -- ? ) request get method>> = ;

: post-request? ( -- ? ) "POST" method= ;

SYMBOL: responder-nesting

SYMBOL: main-responder

SYMBOL: development?

SYMBOL: benchmark?

! path is a sequence of path component strings
GENERIC: call-responder* ( path responder -- response )

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder* nip response>> clone ;

main-responder [ <404> <trivial-responder> ] initialize

: invert-slice ( slice -- slice' )
    dup slice? [ [ seq>> ] [ from>> ] bi head-slice ] [ drop { } ] if ;

: add-responder-nesting ( path responder -- )
    [ invert-slice ] dip 2array responder-nesting get push ;

: call-responder ( path responder -- response )
    [ add-responder-nesting ] [ call-responder* ] 2bi ;

: make-http-error ( error -- xml )
    [ "Internal server error" f ] dip
    [ print-error nl :c ] with-html-writer
    simple-page ;

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    swap development? get [ make-http-error >>body ] [ drop ] if ;

: do-response ( response -- )
    '[ request get _ write-full-response ]
    [
        [ \ do-response log-error ]
        [
            utf8 [
                development? get
                [ make-http-error ] [ drop "Response error" ] if
                write-xml
            ] with-encoded-output
        ] bi
    ] recover ;

LOG: httpd-hit NOTICE

LOG: httpd-header NOTICE

: log-header ( request name -- )
    [ nip ] [ header ] 2bi 2array httpd-header ;

: log-request ( request -- )
    [ [ method>> ] [ url>> ] bi 2array httpd-hit ]
    [ { "user-agent" "x-forwarded-for" } [ log-header ] with each ]
    bi ;

: split-path ( string -- path )
    "/" split harvest ;

: request-params ( request -- assoc )
    dup method>> {
        { "GET" [ url>> query>> ] }
        { "HEAD" [ url>> query>> ] }
        { "OPTIONS" [ url>> query>> ] }
        { "DELETE" [ url>> query>> ] }
        { "POST" [ post-data>> params>> ] }
        { "PATCH" [ post-data>> params>> ] }
        { "PUT" [ post-data>> params>> ] }
        [ 2drop H{ } clone ]
    } case ;

SYMBOL: params

: param ( name -- value )
    params get at ;

: set-param ( value name -- )
    params get set-at ;

: init-request ( request -- )
    [ request set ]
    [ url>> url set ]
    [ request-params >hashtable params set ] tri
    V{ } clone responder-nesting set ;

: dispatch-request ( request -- response )
    url>> path>> split-path main-responder get call-responder ;

: prepare-request ( request -- )
    [
        local-address get
        [ secure? "https" "http" ? >>protocol ]
        [ port>> remap-port >>port ]
        bi
    ] change-url drop ;

: valid-request? ( request -- ? )
    url>> port>> remap-port
    local-address get port>> remap-port = ;

: do-request ( request -- response )
    '[
        _
        {
            [ prepare-request ]
            [ init-request ]
            [ log-request ]
            [ dup valid-request? [ dispatch-request ] [ drop <400> ] if ]
        } cleave
    ] [ [ \ do-request log-error ] [ <500> ] bi ] recover ;

: ?refresh-all ( -- )
    development? get-global [ [ refresh-all ] with-global ] when ;

LOG: httpd-benchmark DEBUG

: ?benchmark ( quot -- )
    benchmark? get [
        [ benchmark ] [ first ] bi url get rot 3array
        httpd-benchmark
    ] [ call ] if ; inline

TUPLE: http-server < threaded-server ;

SYMBOL: request-limit

request-limit [ 64 1024 * ] initialize

LOG: httpd-bad-request NOTICE

: handle-client-error ( error -- )
    dup request-error? [
        dup { [ bad-request-line? ] [ parse-error>> got>> empty? ] } 1&&
        [ drop ] [ httpd-bad-request <400> write-response ] if
    ] [ rethrow ] if ;

M: http-server handle-client*
    drop [
        [
            ?refresh-all
            request-limit get limited-input
            [ read-request ] ?benchmark
            [ do-request ] ?benchmark
            [ do-response ] ?benchmark
        ] [ handle-client-error ] recover
    ] with-destructors ;

: <http-server> ( -- server )
    ascii http-server new-threaded-server
        "http.server" >>name
        "http" lookup-protocol-port >>insecure
        "https" lookup-protocol-port >>secure ;

: httpd ( port -- http-server )
    <http-server>
        swap >>insecure
        f >>secure
    start-server ;

: http-insomniac ( -- )
    "http.server" { "httpd-hit" } schedule-insomniac ;

"http.server.filters" require
"http.server.dispatchers" require
"http.server.redirection" require
"http.server.static" require
"http.server.cgi" require
