! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces io strings splitting
threads http http.server.responders sequences prettyprint
io.server http.server.responders.file
http.server.responders.callback
http.server.responders.continuation ;

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

: host ( -- string )
    #! The host the current responder was called from.
    "Host" "header" get at ":" split1 drop ;

: (handle-request) ( arg cmd -- method path host )
    request-method dup "method" set swap
    prepare-url prepare-header host ;

: handle-request ( arg cmd -- )
    [ (handle-request) serve-responder ] with-scope ;

: parse-request ( request -- )
    dup log-message
    " " split1 dup [
        " HTTP" split1 drop url>path secure-path dup [
            swap handle-request
        ] [
            2drop bad-request
        ] if
    ] [
        2drop bad-request
    ] if ;

: httpd ( port -- )
    "Starting HTTP server on port " write dup . flush
    internet-server "http.server" [
        60000 stdio get set-timeout
        readln [ parse-request ] when*
    ] with-server ;

: httpd-main ( -- ) 8888 httpd ;

MAIN: httpd-main
