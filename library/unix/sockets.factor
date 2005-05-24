! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! We need to fiddle with the exact search order here, since
! unix-internals::accept shadows streams::accept.
IN: io-internals
USING: namespaces streams threads unparser ;
USING: alien generic kernel math unix-internals ;

: init-sockaddr ( port -- sockaddr )
    <sockaddr-in>
    [ AF_INET swap set-sockaddr-in-family ] keep
    [ >r htons r> set-sockaddr-in-port ] keep ;

: client-sockaddr ( host port -- sockaddr )
    #! Error handling here
    init-sockaddr [
        >r gethostbyname hostent-addr
        dup 0 = [ -1 io-error ] when r>
        set-sockaddr-in-addr
    ] keep ;

: socket-fd ( -- socket )
    PF_INET SOCK_STREAM 0 socket dup io-error dup init-handle ;

: with-socket-fd ( quot -- fd | quot: socket -- n )
    socket-fd [ swap call ] keep  swap 0 < [
        errno EINPROGRESS = [
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

TUPLE: accept-task ;

C: accept-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: accept-task do-io-task ( task -- ? ) drop t ;

M: accept-task io-task-events ( task -- events )
    drop POLLIN ;

: wait-to-accept ( server -- )
    [ swap <accept-task> add-io-task stop ] callcc0 drop ;

: inet-ntoa ( n -- str )
    ntohl [
        dup -24 shift HEX: ff bitand unparse % CHAR: . ,
        dup -16 shift HEX: ff bitand unparse % CHAR: . ,
        dup -8  shift HEX: ff bitand unparse % CHAR: . ,
                      HEX: ff bitand unparse %
    ] make-string ;

: do-accept ( fd -- fd host port )
    <sockaddr-in>
    [ "sockaddr-in" c-size <int> accept dup io-error ] keep
    dup sockaddr-in-addr inet-ntoa
    swap sockaddr-in-port ntohs ;

: <socket-stream> ( fd -- stream )
    dup f <fd-stream> ;

: timeout-opt ( fd level opt value -- )
    "timeval" c-size setsockopt io-error ;

IN: streams

C: client-stream ( fd host port -- stream )
    [ set-client-stream-port ] keep
    [ set-client-stream-host ] keep
    [
        >r
        dup SOL_SOCKET SO_OOBINLINE sockopt
        <socket-stream> r> set-delegate
    ] keep ;

: <client> ( host port -- stream )
    #! Connect to a port number on a TCP/IP host.
    client-socket <socket-stream> ;

: <server> ( port -- server )
    #! Starts listening for TCP connections on localhost:port.
    server-socket 0 <port> ;

: accept ( server -- client )
    #! Wait for a client connection.
    dup wait-to-accept port-handle do-accept <client-stream> ;
