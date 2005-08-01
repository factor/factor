! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: http-client
USING: errors http kernel lists namespaces parser sequences
io strings unparser ;

: parse-host ( url -- host port )
    #! Extract the host name and port number from an HTTP URL.
    ":" split1 [ str>number ] [ 80 ] ifte* ;

: parse-url ( url -- host resource )
    "http://" ?head [
        "URL must begin with http://" throw
    ] unless
    "/" split1 [ "/" swap append ] [ "/" ] ifte* ;

: parse-response ( line -- code )
    "HTTP/" ?head [ " " split1 nip ] when
    " " split1 drop str>number ;

: read-response ( -- code header )
    #! After sending a GET oR POST we read a response line and
    #! header.
    flush readln parse-response read-header ;

: http-request ( host resource method -- )
    write CHAR: \s write write " HTTP/1.0" write crlf
    "Host: " write write crlf ;

: get-request ( host resource -- )
    "GET" http-request crlf ;

DEFER: http-get

: do-redirect ( code headers stream -- code headers stream )
    #! Should this support Location: headers that are
    #! relative URLs?
    pick 302 = [
        stream-close "Location" swap assoc nip http-get
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
    "POST" http-request [
        url-encode
        "Content-Length: " write length unparse write crlf
        "Content-Type: " write write crlf
        crlf
    ] keep write ;

: http-post ( content-type content url -- code headers stream )
    #! Make a POST request. The content is URL encoded for you.
    parse-url over parse-host <client> [
        [ post-request flush read-response ] with-stream*
    ] keep ;
