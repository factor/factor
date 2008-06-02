! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences arrays namespaces splitting
vocabs.loader http http.server.responses logging calendar
destructors html.elements html.streams io.server
io.encodings.8-bit io.timeouts io assocs debugger continuations
fry tools.vocabs math ;
IN: http.server

SYMBOL: responder-nesting

SYMBOL: main-responder

SYMBOL: development-mode

! path is a sequence of path component strings
GENERIC: call-responder* ( path responder -- response )

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder* nip response>> clone ;

main-responder global [ <404> <trivial-responder> get-global or ] change-at

: invert-slice ( slice -- slice' )
    dup slice? [ [ seq>> ] [ from>> ] bi head-slice ] [ drop { } ] if ;

: add-responder-nesting ( path responder -- )
    [ invert-slice ] dip 2array responder-nesting get push ;

: call-responder ( path responder -- response )
    [ add-responder-nesting ] [ call-responder* ] 2bi ;

: http-error. ( error -- )
    "Internal server error" [
        [ print-error nl :c ] with-html-stream
    ] simple-page ;

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    development-mode get [ swap '[ , http-error. ] >>body ] [ drop ] if ;

: do-response ( response -- )
    dup write-response
    request get method>> "HEAD" =
    [ drop ] [ '[ , write-response-body ] [ http-error. ] recover ] if ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    [ method>> ] [ url>> [ host>> ] [ path>> ] bi ] bi 3array httpd-hit ;

: split-path ( string -- path )
    "/" split harvest ;

: init-request ( request -- )
    request set
    V{ } clone responder-nesting set ;

: dispatch-request ( request -- response )
    url>> path>> split-path main-responder get call-responder ;

: do-request ( request -- response )
    [
        [ init-request ]
        [ log-request ]
        [ dispatch-request ] tri
    ] [ [ \ do-request log-error ] [ <500> ] bi ] recover ;

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
    "http.server" latin1 [ handle-client ] with-server ;

: httpd-main ( -- )
    8888 httpd ;

MAIN: httpd-main
