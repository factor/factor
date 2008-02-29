! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http sequences prettyprint io.server logging calendar
new-slots html.elements accessors math.parser combinators.lib
vocabs.loader debugger html continuations random ;
IN: http.server

GENERIC: call-responder ( request path responder -- response )

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder 2nip response>> call ;

: trivial-response-body ( code message -- )
    <html>
        <body>
            <h1> swap number>string write bl write </h1>
        </body>
    </html> ;

: <trivial-response> ( code message -- response )
    <response>
    2over [ trivial-response-body ] 2curry >>body
    "text/html" set-content-type
    swap >>message
    swap >>code ;

: <404> ( -- response )
    404 "Not Found" <trivial-response> ;

SYMBOL: 404-responder

[ <404> ] <trivial-responder> 404-responder set-global

: <redirect> ( to code message -- response )
    <trivial-response>
    swap "location" set-header ;

\ <redirect> DEBUG add-input-logging

: <permanent-redirect> ( to -- response )
    301 "Moved Permanently" <redirect> ;

: <temporary-redirect> ( to -- response )
    307 "Temporary Redirect" <redirect> ;

: <content> ( content-type -- response )
    <response>
    200 >>code
    swap set-content-type ;

TUPLE: dispatcher default responders ;

: get-responder ( name dispatcher -- responder )
    tuck responders>> at [ ] [ default>> ] ?if ;

: find-responder ( path dispatcher -- path responder )
    >r [ CHAR: / = ] left-trim "/" split1
    swap [ CHAR: / = ] right-trim r> get-responder ;

: redirect-with-/ ( request -- response )
    dup path>> "/" append >>path
    request-url <permanent-redirect> ;

M: dispatcher call-responder
    over [
        find-responder call-responder
    ] [
        2drop redirect-with-/
    ] if ;

: <dispatcher> ( -- dispatcher )
    404-responder get-global H{ } clone
    dispatcher construct-boa ;

: add-responder ( dispatcher responder path -- dispatcher )
    pick responders>> set-at ;

SYMBOL: virtual-hosts
SYMBOL: default-host

virtual-hosts global [ drop H{ } clone ] cache drop
default-host global [ drop 404-responder get-global ] cache drop

: find-virtual-host ( host -- responder )
    virtual-hosts get at [ default-host get ] unless* ;

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    swap [
        "Internal server error" [
            [ print-error nl :c ] with-html-stream
        ] simple-page
    ] curry >>body ;

: handle-request ( request -- )
    [
        dup dup path>> over host>>
        find-virtual-host call-responder
    ] [ <500> ] recover
    dup write-response
    swap method>> "HEAD" =
    [ drop ] [ write-response-body ] if ;

: default-timeout 1 minutes stdio get set-timeout ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    { method>> host>> path>> } map-exec-with httpd-hit ;

SYMBOL: development-mode

: (httpd) ( -- )
    default-timeout
    development-mode get-global
    [ global [ refresh-all ] bind ] when
    read-request dup log-request handle-request ;

: httpd ( port -- )
    internet-server "http.server" [ (httpd) ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main

: generate-key ( assoc -- str )
    4 big-random >hex dup pick key?
    [ drop generate-key ] [ nip ] if ;
