! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs io.files combinators
arrays io.launcher io http.server.static http.server
http accessors sequences strings math.parser ;
IN: http.server.cgi

: post? request get method>> "POST" = ;

: cgi-variables ( script-path -- assoc )
    #! This needs some work.
    [
        "CGI/1.0" "GATEWAY_INTERFACE" set
        "HTTP/" request get version>> append "SERVER_PROTOCOL" set
        "Factor" "SERVER_SOFTWARE" set

        dup "PATH_TRANSLATED" set
        "SCRIPT_FILENAME" set

        request get path>> "SCRIPT_NAME" set

        request get host>> "SERVER_NAME" set
        request get port>> number>string "SERVER_PORT" set
        "" "PATH_INFO" set
        "" "REMOTE_HOST" set
        "" "REMOTE_ADDR" set
        "" "AUTH_TYPE" set
        "" "REMOTE_USER" set
        "" "REMOTE_IDENT" set

        request get method>> "REQUEST_METHOD" set
        request get query>> assoc>query "QUERY_STRING" set
        request get "cookie" header "HTTP_COOKIE" set 

        request get "user-agent" header "HTTP_USER_AGENT" set
        request get "accept" header "HTTP_ACCEPT" set

        post? [
            request get post-data-type>> "CONTENT_TYPE" set
            request get post-data>> length number>string "CONTENT_LENGTH" set
        ] when
    ] H{ } make-assoc ;

: cgi-descriptor ( name -- desc )
    [
        dup 1array +arguments+ set
        cgi-variables +environment+ set
    ] H{ } make-assoc ;
    
: serve-cgi ( name -- response )
    <raw-response>
    200 >>code
    "CGI output follows" >>message
    swap [
        stdio get swap cgi-descriptor <process-stream> [
            post? [
                request get post-data>> write flush
            ] when
            stdio get swap (stream-copy)
        ] with-stream
    ] curry >>body ;

: enable-cgi ( responder -- responder )
    [ serve-cgi ] "application/x-cgi-script"
    pick special>> set-at ;
