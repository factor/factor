! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: errors httpd-responder kernel lists logging namespaces
stdio streams strings threads url-encoding ;

: httpd-log-stream ( -- stream )
    #! Set httpd-log-file to save httpd log to a file.
    "httpd-log-file" get dup [
        <file-reader>
    ] [
        drop stdio get
    ] ifte ;

: (url>path) ( uri -- path )
    url-decode "http://" ?string-head [
        "/" split1 dup "" ? nip
    ] when ;

: url>path ( uri -- path )
    "?" split1 dup [
      >r (url>path) "?" r> cat3
    ] [
      drop (url>path)
    ] ifte ;

: secure-path ( path -- path )
    ".." over string-contains? [ drop f ] when ;

: request-method ( cmd -- method )
    [
        [[ "GET" "get" ]]
        [[ "POST" "post" ]]
        [[ "HEAD" "head" ]]
    ] assoc [ "bad" ] unless* ;

: (handle-request) ( arg cmd -- url method )
    request-method dup "method" set swap
    prepare-url prepare-header ;

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
    [
        [
            stdio get log-client read-line [ parse-request ] when*
        ] with-stream
    ] try ;

: httpd-connection ( socket -- )
    "http-server" get accept [ httpd-client ] in-thread drop ;

: httpd-loop ( -- )
    [ httpd-connection ] forever ;

: (httpd) ( port -- )
    <server> "http-server" set [
        httpd-loop
    ] [
        "http-server" get stream-close rethrow
    ] catch ;

: httpd ( port -- )
    [ httpd-log-stream "log" set (httpd) ] with-scope ;
