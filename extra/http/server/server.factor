! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http sequences prettyprint io.server logging calendar
new-slots html.elements accessors math.parser combinators.lib
vocabs.loader debugger html continuations random combinators ;
IN: http.server

GENERIC: call-responder ( request path responder -- response )

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder nip response>> call ;

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

: <400> ( -- response )
    400 "Bad request" <trivial-response> ;

: <404> ( -- response )
    404 "Not Found" <trivial-response> ;

SYMBOL: 404-responder

[ drop <404> ] <trivial-responder> 404-responder set-global

: modify-for-redirect ( request to -- url )
    {
        { [ dup "http://" head? ] [ nip ] }
        { [ dup "/" head? ] [ >>path request-url ] }
        { [ t ] [ >r dup path>> "/" last-split1 drop "/" r> 3append >>path request-url ] }
    } cond ;

: <redirect> ( request to code message -- response )
    <trivial-response>
    -rot modify-for-redirect
    "location" set-header ;

\ <redirect> DEBUG add-input-logging

: <permanent-redirect> ( request to -- response )
    301 "Moved Permanently" <redirect> ;

: <temporary-redirect> ( request to -- response )
    307 "Temporary Redirect" <redirect> ;

: <content> ( content-type -- response )
    <response>
    200 >>code
    swap set-content-type ;

TUPLE: dispatcher default responders ;

: <dispatcher> ( -- dispatcher )
    404-responder H{ } clone dispatcher construct-boa ;

: set-main ( dispatcher name -- dispatcher )
    [ <permanent-redirect> ] curry
    <trivial-responder> >>default ;

: split-path ( path -- rest first )
    [ CHAR: / = ] left-trim "/" split1 swap ;

: find-responder ( path dispatcher -- path responder )
    over split-path pick responders>> at*
    [ >r >r 2drop r> r> ] [ 2drop default>> ] if ;

: redirect-with-/ ( request -- response )
    dup path>> "/" append <permanent-redirect> ;

M: dispatcher call-responder
    over [
        3dup find-responder call-responder [
            >r 3drop r>
        ] [
            default>> [
                call-responder
            ] [
                3drop f
            ] if*
        ] if*
    ] [
        2drop redirect-with-/
    ] if ;

: add-responder ( dispatcher responder path -- dispatcher )
    pick responders>> set-at ;

: add-main-responder ( dispatcher responder path -- dispatcher )
    [ add-responder ] keep set-main ;

: <webapp> ( class -- dispatcher )
    <dispatcher> swap construct-delegate ; inline

SYMBOL: virtual-hosts
SYMBOL: default-host

virtual-hosts global [ drop H{ } clone ] cache drop
default-host global [ drop 404-responder get-global ] cache drop

: find-virtual-host ( host -- responder )
    virtual-hosts get at [ default-host get ] unless* ;

SYMBOL: development-mode

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    swap [
        "Internal server error" [
            development-mode get [
                [ print-error nl :c ] with-html-stream
            ] [
                500 "Internal server error"
                trivial-response-body
            ] if
        ] simple-page
    ] curry >>body ;

: do-response ( request response -- )
    dup write-response
    swap method>> "HEAD" =
    [ drop ] [ write-response-body ] if ;

: do-request ( request -- request )
    [
        dup dup path>> over host>>
        find-virtual-host call-responder
        [ <404> ] unless*
    ] [ dup \ do-request log-error <500> ] recover ;

: default-timeout 1 minutes stdio get set-timeout ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    { method>> host>> path>> } map-exec-with httpd-hit ;

: handle-client ( -- )
    default-timeout
    development-mode get-global
    [ global [ refresh-all ] bind ] when
    read-request
    dup log-request
    do-request do-response ;

: httpd ( port -- )
    internet-server "http.server"
    [ handle-client ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main

: generate-key ( assoc -- str )
    4 big-random >hex dup pick key?
    [ drop generate-key ] [ nip ] if ;
