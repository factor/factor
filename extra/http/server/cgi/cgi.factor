! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs io.files io.streams.duplex
combinators arrays io.launcher io http.server.static http.server
http accessors sequences strings math.parser fry urls ;
IN: http.server.cgi

: post? request get method>> "POST" = ;

: cgi-variables ( script-path -- assoc )
    #! This needs some work.
    [
        "CGI/1.0" "GATEWAY_INTERFACE" set
        "HTTP/" request get version>> append "SERVER_PROTOCOL" set
        "Factor" "SERVER_SOFTWARE" set

        [ "PATH_TRANSLATED" set ] [ "SCRIPT_FILENAME" set ] bi

        request get url>> path>> "SCRIPT_NAME" set

        request get url>> host>> "SERVER_NAME" set
        request get url>> port>> number>string "SERVER_PORT" set
        "" "PATH_INFO" set
        "" "REMOTE_HOST" set
        "" "REMOTE_ADDR" set
        "" "AUTH_TYPE" set
        "" "REMOTE_USER" set
        "" "REMOTE_IDENT" set

        request get method>> "REQUEST_METHOD" set
        request get url>> query>> assoc>query "QUERY_STRING" set
        request get "cookie" header "HTTP_COOKIE" set 

        request get "user-agent" header "HTTP_USER_AGENT" set
        request get "accept" header "HTTP_ACCEPT" set

        post? [
            request get post-data>> raw>>
            [ "CONTENT_TYPE" set ]
            [ length number>string "CONTENT_LENGTH" set ]
            bi
        ] when
    ] H{ } make-assoc ;

: <cgi-process> ( name -- desc )
    <process>
        over 1array >>command
        swap cgi-variables >>environment ;

: serve-cgi ( name -- response )
    <raw-response>
    200 >>code
    "CGI output follows" >>message
    swap '[
        , output-stream get swap <cgi-process> <process-stream> [
            post? [ request get post-data>> raw>> write flush ] when
            input-stream get swap (stream-copy)
        ] with-stream
    ] >>body ;

: enable-cgi ( responder -- responder )
    [ serve-cgi ] "application/x-cgi-script"
    pick special>> set-at ;
