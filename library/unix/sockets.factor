! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! We need to fiddle with the exact search order here, since
! unix-internals::accept shadows streams::accept.
IN: io-internals
USING: alien errors generic io kernel math namespaces parser
threads unix-internals ;

: <socket-stream> ( fd -- stream )
    dup f <fd-stream> ;

: init-sockaddr ( port -- sockaddr )
    <sockaddr-in>
    [ AF_INET swap set-sockaddr-in-family ] keep
    [ >r htons r> set-sockaddr-in-port ] keep ;

: client-sockaddr ( host port -- sockaddr )
    #! Error handling here
    init-sockaddr [
        >r gethostbyname dup [
            "Host lookup failed" throw
        ] unless hostent-addr dup check-null
        r> set-sockaddr-in-addr
    ] keep ;

: socket-fd ( -- socket )
    PF_INET SOCK_STREAM 0 socket dup io-error dup init-handle ;

: with-socket-fd ( quot -- fd | quot: socket -- n )
    socket-fd [ swap call ] keep  swap 0 < [
        err_no EINPROGRESS = [
            dup close -1 io-error
        ] unless
    ] when ; inline

: client-socket ( host port -- fd )
    client-sockaddr [
        swap "sockaddr-in" c-size connect
    ] with-socket-fd ;

: server-sockaddr ( port -- sockaddr )
    init-sockaddr  INADDR_ANY htonl over set-sockaddr-in-addr ;

: sockopt ( fd level opt value -- )
    1 <int> "int" c-size setsockopt io-error ;

: server-socket ( port -- fd )
    server-sockaddr [
        dup SOL_SOCKET SO_REUSEADDR sockopt
        swap dupd "sockaddr-in" c-size bind
        dup 0 >= [ drop 1 listen ] [ ( fd n - n) nip ] ifte
    ] with-socket-fd ;

IN: io

C: client-stream ( host port fd -- stream )
    [ >r <socket-stream> r> set-delegate ] keep
    [ set-client-stream-port ] keep
    [ set-client-stream-host ] keep ;

: <client> ( host port -- stream )
    #! Connect to a port number on a TCP/IP host.
    client-socket <socket-stream> ;

TUPLE: server client ;

C: server ( port -- server )
    #! Starts listening for TCP connections on localhost:port.
    [ >r server-socket 0 <port> r> set-delegate ] keep ;

IN: io-internals
USE: unix-internals

TUPLE: accept-task ;

C: accept-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

: init-socket ( fd -- ) SOL_SOCKET SO_OOBINLINE sockopt ;

: inet-ntoa ( n -- str )
    ntohl [
        dup -24 shift HEX: ff bitand # CHAR: . ,
        dup -16 shift HEX: ff bitand # CHAR: . ,
        dup -8  shift HEX: ff bitand # CHAR: . ,
                      HEX: ff bitand #
    ] "" make ;

: do-accept ( port sockaddr fd -- )
    [
        init-socket
        dup sockaddr-in-addr inet-ntoa
        swap sockaddr-in-port ntohs
    ] keep <client-stream> swap set-server-client ;

M: accept-task do-io-task ( task -- ? )
    io-task-port <sockaddr-in>
    over port-handle over "sockaddr-in" c-size <int> accept
    dup 0 >= [
        do-accept t
    ] [
        2drop defer-error
    ] ifte ;

M: accept-task task-container drop read-tasks get ;

: wait-to-accept ( server -- )
    [ swap <accept-task> add-io-task stop ] callcc0 drop ;

: timeout-opt ( fd level opt value -- )
    "timeval" c-size setsockopt io-error ;

IN: io

: accept ( server -- client )
    #! Wait for a client connection.
    dup wait-to-accept  dup pending-error  server-client ;
