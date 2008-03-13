! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http sequences prettyprint io.server logging calendar
new-slots html.elements accessors math.parser combinators.lib
vocabs.loader debugger html continuations random combinators
destructors io.encodings.latin1 fry combinators.cleave ;
IN: http.server

GENERIC: call-responder ( path responder -- response )

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

: url-redirect ( to query -- url )
    #! Different host.
    dup assoc-empty? [
        drop
    ] [
        assoc>query "?" swap 3append
    ] if ;

: absolute-redirect ( to query -- url )
    #! Same host.
    request get clone
        swap [ >>query ] when*
        swap >>path
    request-url ;

: replace-last-component ( path with -- path' )
    >r "/" last-split1 drop "/" r> 3append ;

: relative-redirect ( to query -- url )
    request get clone
    swap [ >>query ] when*
    swap [ '[ , replace-last-component ] change-path ] when*
    request-url ;

: derive-url ( to query -- url )
    {
        { [ over "http://" head? ] [ url-redirect ] }
        { [ over "/" head? ] [ absolute-redirect ] }
        { [ t ] [ relative-redirect ] }
    } cond ;

: <redirect> ( to query code message -- response )
    <trivial-response> -rot derive-url "location" set-header ;

\ <redirect> DEBUG add-input-logging

: <permanent-redirect> ( to query -- response )
    301 "Moved Permanently" <redirect> ;

: <temporary-redirect> ( to query -- response )
    307 "Temporary Redirect" <redirect> ;

TUPLE: dispatcher default responders ;

: <dispatcher> ( -- dispatcher )
    404-responder get H{ } clone dispatcher construct-boa ;

: set-main ( dispatcher name -- dispatcher )
    '[ , f <permanent-redirect> ] <trivial-responder>
    >>default ;

: split-path ( path -- rest first )
    [ CHAR: / = ] left-trim "/" split1 swap ;

: find-responder ( path dispatcher -- path responder )
    over split-path pick responders>> at*
    [ >r >r 2drop r> r> ] [ 2drop default>> ] if ;

: redirect-with-/ ( -- response )
    request get path>> "/" append f <permanent-redirect> ;

M: dispatcher call-responder ( path dispatcher -- response )
    over [
        2dup find-responder call-responder [
            2nip
        ] [
            default>> [
                call-responder
            ] [
                drop f
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

SYMBOL: main-responder

main-responder global
[ drop 404-responder get-global ] cache
drop

SYMBOL: development-mode

: <500> ( error -- response )
    500 "Internal server error" <trivial-response>
    swap '[
        , "Internal server error" [
            development-mode get [
                [ print-error nl :c ] with-html-stream
            ] [
                500 "Internal server error"
                trivial-response-body
            ] if
        ] simple-page
    ] >>body ;

: do-response ( response -- )
    dup write-response
    request get method>> "HEAD" =
    [ drop ] [ write-response-body ] if ;

LOG: httpd-hit NOTICE

: log-request ( request -- )
    { method>> host>> path>> } map-exec-with httpd-hit ;

SYMBOL: exit-continuation

: exit-with exit-continuation get continue-with ;

: do-request ( request -- response )
    '[
        exit-continuation set ,
        [
            [ log-request ]
            [ request set ]
            [ path>> main-responder get call-responder ] tri
            [ <404> ] unless*
        ] [
            [ \ do-request log-error ]
            [ <500> ]
            bi
        ] recover
    ] callcc1
    exit-continuation off ;

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

! Utility
: generate-key ( assoc -- str )
    >r random-256 >hex r>
    2dup key? [ nip generate-key ] [ drop ] if ;

: set-at-unique ( value assoc -- key )
    dup generate-key [ swap set-at ] keep ;
