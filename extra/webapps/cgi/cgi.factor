! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs io.files combinators
arrays io.launcher io http.server.responders webapps.file
sequences strings math.parser unicode.case ;
IN: webapps.cgi

SYMBOL: cgi-root

: post? "method" get "post" = ;

: cgi-variables ( name -- assoc )
    #! This needs some work.
    [
        cgi-root get over path+ "PATH_TRANSLATED" set
        cgi-root get over path+ "SCRIPT_FILENAME" set
        "SCRIPT_NAME" set

        "CGI/1.0" "GATEWAY_INTERFACE" set
        "HTTP/1.0" "SERVER_PROTOCOL" set
        "Factor " version append "SERVER_SOFTWARE" set
        host "SERVER_NAME" set
        "" "SERVER_PORT" set
        "request" get "PATH_INFO" set
        "request" get "PATH_TRANSLATED" set
        "" "REMOTE_HOST" set
        "" "REMOTE_ADDR" set
        "" "AUTH_TYPE" set
        "" "REMOTE_USER" set
        "" "REMOTE_IDENT" set

        "method" get >upper "REQUEST_METHOD" set
        "raw-query" get "QUERY_STRING" set
        "Cookie" header-param "HTTP_COOKIE" set 

        "User-Agent" header-param "HTTP_USER_AGENT" set
        "Accept" header-param "HTTP_ACCEPT" set

        post? [
            "Content-Type" header-param "CONTENT_TYPE" set
            "raw-response" get length number>string "CONTENT_LENGTH" set
        ] when
    ] H{ } make-assoc ;

: cgi-descriptor ( name -- desc )
    [
        cgi-root get over path+ 1array +arguments+ set
        cgi-variables +environment+ set
    ] H{ } make-assoc ;
    
: (do-cgi) ( name -- )
    "200 CGI output follows" response
    stdio get swap cgi-descriptor <process-stream> [
        post? [
            "raw-response" get write flush
        ] when
        stdio get swap (stream-copy)
    ] with-stream ;

: serve-regular-file ( -- )
    cgi-root get doc-root [ file-responder ] with-variable ;

: do-cgi ( name -- )
    {
        { [ dup ".cgi" tail? not ] [ drop serve-regular-file ] }
        { [ dup empty? ] [ "403 forbidden" httpd-error ] }
        { [ cgi-root get not ] [ "404 cgi-root not set" httpd-error ] }
        { [ ".." over subseq? ] [ "403 forbidden" httpd-error ] }
        { [ t ] [ (do-cgi) ] }
    } cond ;

global [
    "cgi" [ "argument" get do-cgi ] add-simple-responder
] bind
