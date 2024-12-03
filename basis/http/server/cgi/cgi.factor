! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar http http.server io
io.backend io.encodings io.encodings.binary io.launcher
io.streams.duplex kernel make math.parser namespaces sequences
urls urls.encoding ;
IN: http.server.cgi

: cgi-variables ( script-path -- assoc )
    ! This needs some work.
    [
        "CGI/1.0" "GATEWAY_INTERFACE" ,,
        "HTTP/" request get version>> append "SERVER_PROTOCOL" ,,
        "Factor" "SERVER_SOFTWARE" ,,

        [ "PATH_TRANSLATED" ,, ] [ "SCRIPT_FILENAME" ,, ] bi

        url get path>> "SCRIPT_NAME" ,,

        url get host>> "SERVER_NAME" ,,
        url get port>> number>string "SERVER_PORT" ,,
        "" "PATH_INFO" ,,
        "" "REMOTE_HOST" ,,
        "" "REMOTE_ADDR" ,,
        "" "AUTH_TYPE" ,,
        "" "REMOTE_USER" ,,
        "" "REMOTE_IDENT" ,,

        request get method>> "REQUEST_METHOD" ,,
        url get query>> assoc>query "QUERY_STRING" ,,
        request get "cookie" header "HTTP_COOKIE" ,,

        request get "user-agent" header "HTTP_USER_AGENT" ,,
        request get "accept" header "HTTP_ACCEPT" ,,

        post-request? [
            request get data>> data>>
            [ "CONTENT_TYPE" ,, ]
            [ length number>string "CONTENT_LENGTH" ,, ]
            bi
        ] when
    ] H{ } make ;

: <cgi-process> ( name -- desc )
    <process>
        over 1array >>command
        swap cgi-variables >>environment
        1 minutes >>timeout ;

: serve-cgi ( name -- response )
    <raw-response>
    200 >>code
    "CGI output follows" >>message
    swap '[
        binary encode-output
        output-stream get _ normalize-path <cgi-process> binary <process-stream> [
            post-request? [ request get data>> data>> write flush ] when
            '[ _ stream-write ] each-block
        ] with-stream
    ] >>body ;

SLOT: special

: enable-cgi ( responder -- responder )
    [ serve-cgi ] "application/x-cgi-script"
    pick special>> set-at ;
