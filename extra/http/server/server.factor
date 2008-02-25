! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http sequences prettyprint io.server logging calendar
new-slots html.elements accessors math.parser combinators.lib ;
IN: http.server

TUPLE: responder path directory ;

: <responder> ( path -- responder )
    "/" ?tail responder construct-boa ;

GENERIC: do-responder ( request path responder -- quot response )

TUPLE: trivial-responder quot response ;

: <trivial-responder> ( quot response -- responder )
    trivial-responder construct-boa
    "" <responder> over set-delegate ;

M: trivial-responder do-responder
    2nip dup quot>> swap response>> ;

: trivial-response-body ( code message -- )
    <html>
        <body>
            <h1> swap number>string write bl write </h1>
        </body>
    </html> ;

: <trivial-response> ( code message -- quot response )
    [ [ trivial-response-body ] 2curry ] 2keep <response>
    "text/html" set-content-type
    swap >>message
    swap >>code ;

: <404> ( -- quot response )
    404 "Not Found" <trivial-response> ;

: <redirect> ( to code message -- quot response )
    <trivial-response>
    rot "location" set-response-header ;

: <permanent-redirect> ( to -- quot response )
    301 "Moved Permanently" <redirect> ;

: <temporary-redirect> ( to -- quot response )
    307 "Temporary Redirect" <redirect> ;

: <content> ( content-type -- response )
    <response>
    200 >>code
    swap set-content-type ;

TUPLE: dispatcher responders default ;

: responder-matches? ( path responder -- ? )
    path>> head? ;

TUPLE: no-/-responder ;

M: no-/-responder do-responder
    2drop
    dup path>> "/" append >>path
    request-url <permanent-redirect> ;

: <no-/-responder> ( -- responder )
    "" <responder> no-/-responder construct-delegate ;

<no-/-responder> no-/-responder set-global

: find-responder ( path dispatcher -- path responder )
    >r "/" ?head drop r>
    [ responders>> [ dupd responder-matches? ] find nip ] keep
    default>> or [ path>> ?head drop ] keep ;

: no-trailing-/ ( path responder -- path responder )
    over empty? over directory>> and
    [ drop no-/-responder get-global ] when ;

: call-responder ( request path responder -- quot response )
    no-trailing-/ do-responder ;

SYMBOL: 404-responder

<404> <trivial-responder> 404-responder set-global

M: dispatcher do-responder
    find-responder call-responder ;

: <dispatcher> ( path -- dispatcher )
    <responder>
    dispatcher construct-delegate
    404-responder get-global >>default
    V{ } clone >>responders ;

: add-responder ( dispatcher responder -- dispatcher )
    over responders>> push ;

SYMBOL: virtual-hosts
SYMBOL: default-host

virtual-hosts global [ drop H{ } clone ] cache drop
default-host global [ drop 404-responder ] cache drop

: find-virtual-host ( host -- responder )
    virtual-hosts get at [ default-host get ] unless* ;

: handle-request ( request -- )
    [
        dup path>> over host>> find-virtual-host
        call-responder
        write-response
    ] keep method>> "HEAD" = [ drop ] [ call ] if ;

: default-timeout 1 minutes stdio get set-timeout ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    { method>> host>> path>> } map-exec-with httpd-hit ;

: httpd ( port -- )
    internet-server "http.server" [
        default-timeout
        read-request dup log-request handle-request
    ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main
