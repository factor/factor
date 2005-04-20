! Copyright (C) 2003, 2005 Slava Pestov, Chris Double
IN: httpd
USING: kernel lists logging namespaces parser sequences stdio
strings url-encoding ;

: print-header ( alist -- )
    [ unswons write ": " write url-encode print ] each ;

: response ( header msg -- )
    "HTTP/1.0 " write print print-header ;

: error-body ( error -- body )
    "<html><body><h1>" swap "</h1></body></html>" cat3 print ;

: error-head ( error -- )
    dup log-error
    [ [[ "Content-Type" "text/html" ]] ] over response ;

: httpd-error ( error -- )
    #! This must be run from handle-request
    error-head
    "head" "method" get = [ terpri error-body ] unless ;

: bad-request ( -- )
    [
        ! Make httpd-error print a body
        "get" "method" set
        "400 Bad request" httpd-error
    ] with-scope ;

: serving-html ( -- )
    [ [[ "Content-Type" "text/html" ]] ]
    "200 Document follows" response terpri ;

: serving-text ( -- )
    [ [[ "Content-Type" "text/plain" ]] ]
    "200 Document follows" response terpri ;

: redirect ( to -- )
    "Location" swons unit
    "301 Moved Permanently" response terpri ;

: directory-no/ ( -- )
    [
        "request" get , CHAR: / ,
        "raw-query" get [ CHAR: ? , , ] when*
    ] make-string redirect ;

: header-line ( alist line -- alist )
    ": " split1 dup [ cons swons ] [ 2drop ] ifte ;

: (read-header) ( alist -- alist )
    read-line dup
    empty? [ drop ] [ header-line (read-header) ] ifte ;

: read-header ( -- alist )
    [ ] (read-header) ;

: content-length ( alist -- length )
    "Content-Length" swap assoc parse-number ;

: query>alist ( query -- alist )
    dup [
        "&" split [
            "=" split1
            dup [ url-decode ] when swap
            dup [ url-decode ] when swap cons
        ] map
    ] when ;

: read-post-request ( header -- alist )
    content-length dup [ read query>alist ] when ;

: log-user-agent ( alist -- )
    "User-Agent" swap assoc* [
        unswons [ , ": " , , ] make-string log
    ] when* ;

: prepare-url ( url -- url )
    #! This is executed in the with-request namespace.
    "?" split1
    dup "raw-query" set query>alist "query" set
    dup "request" set ;

: prepare-header ( -- )
    read-header dup "header" set
    dup log-user-agent
    read-post-request "response" set ;
