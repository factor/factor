! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: http-client
USING: errors http kernel lists namespaces parser sequences
stdio streams strings ;

: parse-host ( url -- host port )
    #! Extract the host name and port number from an HTTP URL.
    ":" split1 [ parse-number ] [ 80 ] ifte* ;

: parse-url ( url -- host resource )
    "http://" ?string-head [
        "URL must begin with http://" throw
    ] unless
    "/" split1 [ "/" swap append ] [ "/" ] ifte* ;

: parse-response ( line -- code )
    "HTTP/" ?string-head [ " " split1 nip ] when
    " " split1 drop parse-number ;

: read-response ( -- code )
    #! Read a response line.
    read-line parse-response ;

: get-request ( host resource -- )
    "GET " write write " HTTP/1.0" write crlf
    "Host: " write write crlf crlf
    flush ;

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
        [
            get-request
            read-response
            read-header
        ] with-stream*
    ] keep do-redirect ;

: download ( url file -- )
    #! Downloads the contents of a URL to a file.
    >r http-get 2nip r> <file-writer> stream-copy ;
