! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: errors kernel lists namespaces
stdio streams strings threads http sequences ;

: (url>path) ( uri -- path )
    url-decode "http://" ?head [
        "/" split1 dup "" ? nip
    ] when ;

: url>path ( uri -- path )
    "?" split1 dup [
      >r (url>path) "?" r> append3
    ] [
      drop (url>path)
    ] ifte ;

: secure-path ( path -- path )
    ".." over subseq? [ drop f ] when ;

: request-method ( cmd -- method )
    [
        [[ "GET" "get" ]]
        [[ "POST" "post" ]]
        [[ "HEAD" "head" ]]
    ] assoc [ "bad" ] unless* ;

: host ( -- string )
    #! The host the current responder was called from.
    "Host" "header" get assoc ":" split1 drop ;

: (handle-request) ( arg cmd -- method path host )
    request-method dup "method" set swap
    prepare-url prepare-header host ;

: handle-request ( arg cmd -- )
    [ (handle-request) serve-responder ] with-scope ;

: parse-request ( request -- )
    dup log
    " " split1 dup [
        " HTTP" split1 drop url>path secure-path dup [
            swap handle-request
        ] [
            2drop bad-request
        ] ifte
    ] [
        2drop bad-request
    ] ifte ;

: httpd-client ( socket -- )
    dup log-client [
        60000 stdio get set-timeout
        read-line [ parse-request ] when*
    ] with-stream ;

: httpd-connection ( socket -- )
    "http-server" get accept [ httpd-client ] in-thread drop ;

: httpd-loop ( -- ) httpd-connection httpd-loop ;

: httpd ( port -- )
    <server> "http-server" set [
        [ httpd-loop ]
        [ "http-server" get stream-close rethrow ] catch
    ] with-logging ;

: stop-httpd ( -- )
    #! Stop the server.
    "http-server" get stream-close ;
