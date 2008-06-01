! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads sequences prettyprint io.server logging calendar http
html.streams html.components html.elements html.templates
accessors math.parser combinators.lib tools.vocabs debugger
continuations random combinators destructors io.streams.string
io.encodings.8-bit fry classes words math urls
arrays vocabs.loader ;
IN: http.server

! path is a sequence of path component strings
GENERIC: call-responder* ( path responder -- response )

: <content> ( body content-type -- response )
    <response>
        200 >>code
        "Document follows" >>message
        swap >>content-type
        swap >>body ;

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder* nip response>> call ;

: trivial-response-body ( code message -- )
    <html>
        <body>
            <h1> [ number>string write bl ] [ write ] bi* </h1>
        </body>
    </html> ;

: <trivial-response> ( code message -- response )
    2dup [ trivial-response-body ] with-string-writer
    "text/html" <content>
        swap >>message
        swap >>code ;

: <400> ( -- response )
    400 "Bad request" <trivial-response> ;

: <404> ( -- response )
    404 "Not Found" <trivial-response> ;

SYMBOL: 404-responder

[ <404> ] <trivial-responder> 404-responder set-global

SYMBOL: responder-nesting

: invert-slice ( slice -- slice' )
    dup slice? [
        [ seq>> ] [ from>> ] bi head-slice
    ] [
        drop { }
    ] if ;

: vocab-path ( vocab -- path )
    dup vocab-dir vocab-append-path ;

: vocab-path-of ( dispatcher -- path )
    class word-vocabulary vocab-path ;

: add-responder-path ( path dispatcher -- )
    [ [ invert-slice ] [ [ vocab-path-of ] keep ] bi* 3array ]
    [ nip class word-name ] 2bi
    responder-nesting get set-at ;

: call-responder ( path responder -- response )
    [ add-responder-path ] [ call-responder* ] 2bi ;

: nested-responders ( -- seq )
    responder-nesting get assocs:values [ third ] map ;

: each-responder ( quot -- )
   nested-responders swap each ; inline

: responder-path ( string -- pair )
    dup responder-nesting get at
    [ ] [ "No such responder: " swap append throw ] ?if ;

: base-path ( string -- path )
    responder-path first ;

: template-path ( string -- path )
    responder-path second ;

: resolve-responder-path ( string quot -- string' )
    [ "$" ?head ] dip '[
        [
            "/" split1 [ @ [ "/" % % ] each "/" % ] dip %
        ] "" make
    ] when ; inline

: resolve-base-path ( string -- string' )
    [ base-path ] resolve-responder-path ;

: resolve-template-path ( string -- string' )
    [ template-path ] resolve-responder-path ;

GENERIC: modify-query ( query responder -- query' )

M: object modify-query drop ;

: adjust-url ( url -- url' )
    clone
        [ dup [ modify-query ] each-responder ] change-query
        [ resolve-base-path ] change-path
    request get url>>
        clone
        f >>query
    swap derive-url ensure-port ;

: <custom-redirect> ( url code message -- response )
    <trivial-response>
        swap dup url? [ adjust-url ] when
        "location" set-header ;

\ <custom-redirect> DEBUG add-input-logging

: <permanent-redirect> ( to query -- response )
    301 "Moved Permanently" <custom-redirect> ;

: <temporary-redirect> ( to query -- response )
    307 "Temporary Redirect" <custom-redirect> ;

: <redirect> ( to query -- response )
    request get method>> {
        { "GET" [ <temporary-redirect> ] }
        { "HEAD" [ <temporary-redirect> ] }
        { "POST" [ <permanent-redirect> ] }
    } case ;

TUPLE: dispatcher default responders ;

: new-dispatcher ( class -- dispatcher )
    new
        404-responder get >>default
        H{ } clone >>responders ; inline

: <dispatcher> ( -- dispatcher )
    dispatcher new-dispatcher ;

: find-responder ( path dispatcher -- path responder )
    over empty? [
        "" over responders>> at*
        [ nip ] [ drop default>> ] if
    ] [
        over first over responders>> at*
        [ [ drop rest-slice ] dip ] [ drop default>> ] if
    ] if ;

M: dispatcher call-responder* ( path dispatcher -- response )
    find-responder call-responder ;

TUPLE: vhost-dispatcher default responders ;

: <vhost-dispatcher> ( -- dispatcher )
    404-responder get H{ } clone vhost-dispatcher boa ;

: find-vhost ( dispatcher -- responder )
    request get url>> host>> over responders>> at*
    [ nip ] [ drop default>> ] if ;

M: vhost-dispatcher call-responder* ( path dispatcher -- response )
    find-vhost call-responder ;

: add-responder ( dispatcher responder path -- dispatcher )
    pick responders>> set-at ;

: add-main-responder ( dispatcher responder path -- dispatcher )
    [ add-responder drop ]
    [ drop "" add-responder drop ]
    [ 2drop ] 3tri ;

TUPLE: filter-responder responder ;

M: filter-responder call-responder*
    responder>> call-responder ;

SYMBOL: main-responder

main-responder global
[ drop 404-responder get-global ] cache
drop

SYMBOL: development-mode

: http-error. ( error -- )
    "Internal server error" [
        development-mode get [
            [ print-error nl :c ] with-html-stream
        ] [
            500 "Internal server error"
            trivial-response-body
        ] if
    ] simple-page ;

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    swap '[ , http-error. ] >>body ;

: do-response ( response -- )
    dup write-response
    request get method>> "HEAD" =
    [ drop ] [
        '[
            , write-response-body
        ] [
            http-error.
        ] recover
    ] if ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    [ method>> ] [ url>> [ host>> ] [ path>> ] bi ] bi 3array httpd-hit ;

: split-path ( string -- path )
    "/" split harvest ;

: init-request ( request -- )
    request set
    H{ } clone responder-nesting set
    [ ] link-hook set
    [ ] form-hook set ;

: dispatch-request ( request -- response )
    url>> path>> split-path main-responder get call-responder ;

: do-request ( request -- response )
    [
        [ init-request ]
        [ log-request ]
        [ dispatch-request ] tri
    ]
    [ [ \ do-request log-error ] [ <500> ] bi ]
    recover ;

: ?refresh-all ( -- )
    development-mode get-global
    [ global [ refresh-all ] bind ] when ;

: handle-client ( -- )
    [
        1 minutes timeouts
        ?refresh-all
        read-request
        do-request
        do-response
    ] with-destructors ;

: httpd ( port -- )
    dup integer? [ internet-server ] when
    "http.server" latin1
    [ handle-client ] with-server ;

: httpd-main ( -- )
    8888 httpd ;

MAIN: httpd-main
