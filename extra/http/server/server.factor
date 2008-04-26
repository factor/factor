! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http sequences prettyprint io.server logging calendar
html.elements accessors math.parser combinators.lib
tools.vocabs debugger html continuations random combinators
destructors io.encodings.8-bit fry classes words ;
IN: http.server

! path is a sequence of path component strings

GENERIC: call-responder ( path responder -- response )

: request-params ( -- assoc )
    request get dup method>> {
        { "GET" [ query>> ] }
        { "HEAD" [ query>> ] }
        { "POST" [ post-data>> ] }
    } case ;

: <content> ( content-type -- response )
    <response>
        200 >>code
        "Document follows" >>message
        swap set-content-type ;

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder nip response>> call ;

: trivial-response-body ( code message -- )
    <html>
        <body>
            <h1> [ number>string write bl ] [ write ] bi* </h1>
        </body>
    </html> ;

: <trivial-response> ( code message -- response )
    2dup '[ , , trivial-response-body ]
    "text/html" <content>
        swap >>body
        swap >>message
        swap >>code ;

: <400> ( -- response )
    400 "Bad request" <trivial-response> ;

: <404> ( -- response )
    404 "Not Found" <trivial-response> ;

SYMBOL: 404-responder

[ <404> ] <trivial-responder> 404-responder set-global

SYMBOL: base-paths

: invert-slice ( slice -- slice' )
    dup slice? [
        [ seq>> ] [ from>> ] bi head-slice
    ] [
        drop { }
    ] if ;

: add-base-path ( path dispatcher -- )
    [ invert-slice ] [ class word-name ] bi*
    base-paths get set-at ;

SYMBOL: link-hook

: add-link-hook ( quot -- )
    link-hook [ compose ] change ; inline

: modify-query ( query -- query )
    link-hook get call ;

: base-path ( string -- path )
    dup base-paths get at
    [ ] [ "No such responder: " swap append throw ] ?if ;

: resolve-base-path ( string -- string' )
    "$" ?head [
        [
            "/" split1 >r
            base-path [ "/" % % ] each "/" %
            r> %
        ] "" make
    ] when ;

: link>string ( url query -- url' )
    [ resolve-base-path ] [ modify-query ] bi* (link>string) ;

: write-link ( url query -- )
    link>string write ;

SYMBOL: form-hook

: add-form-hook ( quot -- )
    form-hook [ compose ] change ;

: hidden-form-field ( -- )
    form-hook get call ;

: absolute-redirect ( to query -- url )
    #! Same host.
    request get clone
    swap [ >>query ] when*
    swap url-encode >>path
    [ modify-query ] change-query
    request-url ;

: replace-last-component ( path with -- path' )
    >r "/" last-split1 drop "/" r> 3append ;

: relative-redirect ( to query -- url )
    request get clone
    swap [ >>query ] when*
    swap [ '[ , replace-last-component ] change-path ] when*
    [ modify-query ] change-query
    request-url ;

: derive-url ( to query -- url )
    {
        { [ over "http://" head? ] [ link>string ] }
        { [ over "/" head? ] [ absolute-redirect ] }
        { [ over "$" head? ] [ >r resolve-base-path r> derive-url ] }
        [ relative-redirect ]
    } cond ;

: <redirect> ( to query code message -- response )
    <trivial-response> -rot derive-url "location" set-header ;

\ <redirect> DEBUG add-input-logging

: <permanent-redirect> ( to query -- response )
    301 "Moved Permanently" <redirect> ;

: <temporary-redirect> ( to query -- response )
    307 "Temporary Redirect" <redirect> ;

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
        [ >r drop rest-slice r> ] [ drop default>> ] if
    ] if ;

M: dispatcher call-responder ( path dispatcher -- response )
    [ add-base-path ] [ find-responder call-responder ] 2bi ;

TUPLE: vhost-dispatcher default responders ;

: <vhost-dispatcher> ( -- dispatcher )
    404-responder get H{ } clone vhost-dispatcher boa ;

: find-vhost ( dispatcher -- responder )
    request get host>> over responders>> at*
    [ nip ] [ drop default>> ] if ;

M: vhost-dispatcher call-responder ( path dispatcher -- response )
    find-vhost call-responder ;

: add-responder ( dispatcher responder path -- dispatcher )
    pick responders>> set-at ;

: add-main-responder ( dispatcher responder path -- dispatcher )
    [ add-responder drop ]
    [ drop "" add-responder drop ]
    [ 2drop ] 3tri ;

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
    { method>> host>> path>> } map-exec-with httpd-hit ;

SYMBOL: exit-continuation

: exit-with exit-continuation get continue-with ;

: with-exit-continuation ( quot -- )
    '[ exit-continuation set @ ] callcc1 exit-continuation off ;

: split-path ( string -- path )
    "/" split [ empty? not ] filter ;

: do-request ( request -- response )
    [
        H{ } clone base-paths set
        [ ] link-hook set
        [ ] form-hook set

        [ log-request ]
        [ request set ]
        [ path>> split-path main-responder get call-responder ] tri
        [ <404> ] unless*
    ] [
        [ \ do-request log-error ]
        [ <500> ]
        bi
    ] recover ;

: default-timeout 1 minutes stdio get set-timeout ;

: ?refresh-all ( -- )
    development-mode get-global
    [ global [ refresh-all ] bind ] when ;

: handle-client ( -- )
    [
        default-timeout
        ?refresh-all
        read-request
        do-request
        do-response
    ] with-destructors ;

: httpd ( port -- )
    internet-server "http.server"
    latin1 [ handle-client ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main
