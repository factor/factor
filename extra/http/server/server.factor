! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io io.timeouts strings splitting
threads http http.server.responders sequences prettyprint
io.server logging calendar io.encodings.latin1 ;

IN: http.server

: (url>path) ( uri -- path )
    url-decode "http://" ?head [
        "/" split1 dup "" ? nip
    ] when ;

: url>path ( uri -- path )
    "?" split1 dup [
      >r (url>path) "?" r> 3append
    ] [
      drop (url>path)
    ] if ;

: secure-path ( path -- path )
    ".." over subseq? [ drop f ] when ;

: request-method ( cmd -- method )
    H{
        { "GET" "get" }
        { "POST" "post" }
        { "HEAD" "head" }
    } at "bad" or ;

: (handle-request) ( arg cmd -- method path host )
    request-method dup "method" set swap
    prepare-url prepare-header host ;

: handle-request ( arg cmd -- )
    [ (handle-request) serve-responder ] with-scope ;

: parse-request ( request -- )
    " " split1 dup [
        " HTTP" split1 drop url>path secure-path dup [
            swap handle-request
        ] [
            2drop bad-request
        ] if
    ] [
        2drop bad-request
    ] if ;

\ parse-request NOTICE add-input-logging

: httpd ( port -- )
    internet-server "http.server" latin1 [
        1 minutes stdio get set-timeout
        readln [ parse-request ] when*
    ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main

! Load default webapps
USE: webapps.file
USE: webapps.callback
USE: webapps.continuation
USE: webapps.cgi
