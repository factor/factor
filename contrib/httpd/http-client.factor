! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: http-client
USING: errors hashtables http kernel math namespaces parser
sequences io strings ;

: parse-host ( url -- host port )
    #! Extract the host name and port number from an HTTP URL.
    ":" split1 [ string>number ] [ 80 ] if* ;

: parse-url ( url -- host resource )
    "http://" ?head [
        "URL must begin with http://" throw
    ] unless
    "/" split1 [ "/" swap append ] [ "/" ] if* ;

: parse-response ( line -- code )
    "HTTP/" ?head [ " " split1 nip ] when
    " " split1 drop string>number ;

: read-response ( -- code header )
    #! After sending a GET or POST we read a response line and
    #! header.
    flush readln parse-response read-header ;

: crlf "\r\n" write ;

: http-request ( host resource method -- )
    write " " write write " HTTP/1.0" write crlf
    "Host: " write write crlf ;

: get-request ( host resource -- )
    "GET" http-request crlf ;

DEFER: http-get

: do-redirect ( code headers stream -- code headers stream )
    #! Should this support Location: headers that are
    #! relative URLs?
    pick 302 = [
        stream-close "Location" swap hash nip http-get
    ] when ;

: http-get ( url -- code headers stream )
    #! Opens a stream for reading from an HTTP URL.
    parse-url over parse-host <client> [
        [ get-request read-response ] with-stream*
    ] keep do-redirect ;

: download ( url file -- )
    #! Downloads the contents of a URL to a file.
    >r http-get 2nip r> <file-writer> stream-copy ;

: post-request ( content-type content host resource -- )
    #! Note: It is up to the caller to url encode the content if
    #! it is required according to the content-type.
    "POST" http-request [
        "Content-Length: " write length number>string write crlf
        "Content-Type: " write url-encode write crlf
        crlf
    ] keep write ;

: http-post ( content-type content url -- code headers stream )
    #! Make a POST request. The content is URL encoded for you.
    parse-url over parse-host <client> [
        [ post-request flush read-response ] with-stream*
    ] keep ;
