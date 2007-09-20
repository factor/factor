! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs http kernel math math.parser namespaces sequences
io io.sockets io.streams.string io.files strings splitting
continuations ;
IN: http.client

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
    " " split1 drop string>number [
        "Premature end of stream" throw
    ] unless* ;

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

DEFER: http-get-stream

: do-redirect ( code headers stream -- code headers stream )
    #! Should this support Location: headers that are
    #! relative URLs?
    pick 100 /i 3 = [
        stream-close "Location" swap at nip http-get-stream
    ] when ;

: http-get-stream ( url -- code headers stream )
    #! Opens a stream for reading from an HTTP URL.
    parse-url over parse-host <inet> <client> [
        [ [ get-request read-response ] with-stream* ] keep
    ] [ >r stream-close r> rethrow ] recover do-redirect ;

: http-get ( url -- code headers string )
    #! Opens a stream for reading from an HTTP URL.
    http-get-stream [ stdio get contents ] with-stream ;

: download ( url file -- )
    #! Downloads the contents of a URL to a file.
    >r http-get 2nip r> <file-writer> [ write ] with-stream ;

: post-request ( content-type content host resource -- )
    #! Note: It is up to the caller to url encode the content if
    #! it is required according to the content-type.
    "POST" http-request [
        "Content-Length: " write length number>string write crlf
        "Content-Type: " write url-encode write crlf
        crlf
    ] keep write ;

: http-post ( content-type content url -- code headers string )
    #! Make a POST request. The content is URL encoded for you.
    parse-url over parse-host <inet> <client> [
        post-request flush read-response stdio get contents
    ] with-stream ;
