! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors command-line concurrency.messaging http.server
http.server.static io io.pathnames io.servers kernel
logging.server namespaces sequences threads ;

IN: file-server

: file-server-logging ( quot -- )
    [
        init-namespaces
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

: file-server-main ( -- )
    [
        command-line get ?first current-directory get or
        <static>
            t >>allow-listings
        main-responder set-global
        8080 httpd wait-for-server
    ] file-server-logging ;

MAIN: file-server-main
