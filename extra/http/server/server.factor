! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences arrays namespaces splitting
vocabs.loader destructors assocs debugger continuations
tools.vocabs math
io
io.server
io.encodings
io.encodings.utf8
io.encodings.ascii
io.encodings.binary
io.streams.limited
io.timeouts
fry logging calendar
http
http.server.responses
html.elements
html.streams ;
IN: http.server

SYMBOL: responder-nesting

SYMBOL: main-responder

SYMBOL: development-mode

! path is a sequence of path component strings
GENERIC: call-responder* ( path responder -- response )

TUPLE: trivial-responder response ;

C: <trivial-responder> trivial-responder

M: trivial-responder call-responder* nip response>> clone ;

main-responder global [ <404> <trivial-responder> or ] change-at

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
    swap development-mode get [ '[ , http-error. ] >>body ] [ drop ] if ;

: do-response ( response -- )
    [ write-response ]
    [
        request get method>> "HEAD" = [ drop ] [
            '[
                ,
                [ content-charset>> encode-output ]
                [ write-response-body ]
                bi
            ]
            [
                utf8 [
                    development-mode get
                    [ http-error. ] [ drop "Response error" throw ] if
                ] with-encoded-output
            ] recover
        ] if
    ] bi ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    [ method>> ] [ url>> [ host>> ] [ path>> ] bi ] bi
    3array httpd-hit ;

: split-path ( string -- path )
    "/" split harvest ;

: init-request ( request -- )
    request set
    V{ } clone responder-nesting set ;

: dispatch-request ( request -- response )
    url>> path>> split-path main-responder get call-responder ;

: do-request ( request -- response )
    '[
        ,
        [ init-request ]
        [ log-request ]
        [ dispatch-request ] tri
    ] [ [ \ do-request log-error ] [ <500> ] bi ] recover ;

: ?refresh-all ( -- )
    development-mode get-global
    [ global [ refresh-all ] bind ] when ;

: setup-limits ( -- )
    1 minutes timeouts
    64 1024 * limit-input ;

: handle-client ( -- )
    [
        setup-limits
        ascii decode-input
        ascii encode-output
        ?refresh-all
        read-request
        do-request
        do-response
    ] with-destructors ;

: httpd ( port -- )
    dup integer? [ internet-server ] when
    "http.server" binary [ handle-client ] with-server ;

: httpd-main ( -- )
    8888 httpd ;

MAIN: httpd-main
