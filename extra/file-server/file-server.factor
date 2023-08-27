! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors command-line concurrency.messaging http.server
http.server.cgi http.server.static io io.pathnames io.servers
kernel logging.server namespaces sequences threads ;

IN: file-server

: file-server-logging ( quot -- )
    [
        init-namestack
        receive

        dup first "log-message" = [
            dup last "http.server" = [
                dup rest first3 write-message flush
            ] when
        ] when

        "log-server" get-global send t
    ] "Log server (file-server)" spawn-server "log-server" [
        call
    ] with-variable ; inline

: file-server-args ( command-line -- cgi? path/f )
    "--cgi" swap [ member? ] [ remove ?first ] 2bi ;

: file-server-main ( -- )
    [
        command-line get file-server-args "." or
        <static>
            t >>allow-listings
        swap [ enable-cgi ] when
        main-responder set-global
        8080 httpd wait-for-server
    ] file-server-logging ;

MAIN: file-server-main
