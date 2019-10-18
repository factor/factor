! Copyright (C) 2004, 2007 Slava Pestov, Ivan Tikhonov.
! See http://factorcode.org/license.txt for BSD license.

! We need to fiddle with the exact search order here, since
! unix-internals::accept shadows streams::accept.
IN: io-internals
USING: alien errors generic io kernel math namespaces
nonblocking-io parser threads unix-internals sequences
byte-arrays ;

: init-sockaddr ( port -- sockaddr )
    "sockaddr-in" <c-object>
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

: socket-fd ( type -- socket )
    PF_INET swap 0 socket dup io-error dup init-handle ;

: with-socket-fd ( type quot -- fd )
    >r socket-fd r> keep  swap 0 < [
        err_no EINPROGRESS = [ dup close (io-error) ] unless
    ] when ; inline

: server-sockaddr ( port -- sockaddr )
    init-sockaddr  INADDR_ANY htonl over set-sockaddr-in-addr ;

: sockopt ( fd level opt -- )
    1 <int> "int" heap-size setsockopt io-error ;

: bind-socket ( port fd -- n )
    dup SOL_SOCKET SO_REUSEADDR sockopt
    swap "sockaddr-in" heap-size bind ;

: server-socket ( port -- fd )
    server-sockaddr SOCK_STREAM [
        tuck bind-socket dup 0 >= [ drop 1 listen ] [ nip ] if
    ] with-socket-fd ;

TUPLE: connect-task ;

C: connect-task ( port -- task ) [ delegate>io-task ] keep ;

M: connect-task do-io-task
    io-task-port dup port-handle f 0 write
    0 < [ defer-error ] [ drop t ] if ;

M: connect-task task-container drop write-tasks get-global ;

: client-socket ( host port -- fd )
    client-sockaddr SOCK_STREAM [
        swap "sockaddr-in" heap-size connect
    ] with-socket-fd ;

: wait-to-connect ( port -- )
    [ swap <connect-task> add-io-task stop ] callcc0 drop ;

! TCP

IN: network

: <client> ( host port -- stream )
    client-socket dup <fd-stream>
    dup duplex-stream-out dup wait-to-connect pending-error ;

C: client-stream ( host port fd -- stream )
    [ >r dup <fd-stream> r> set-delegate ] keep
    [ set-client-stream-port ] keep
    [ set-client-stream-host ] keep ;

TUPLE: server client ;

C: server ( port -- server )
    #! Starts listening for TCP connections on localhost:port.
    [ >r server-socket f <port> r> set-delegate ] keep
    server over set-port-type ;

IN: io-internals
USE: unix-internals

TUPLE: accept-task ;

C: accept-task ( port -- task ) [ delegate>io-task ] keep ;

: init-socket ( fd -- ) SOL_SOCKET SO_OOBINLINE sockopt ;

: inet-ntoa ( n -- str )
    ntohl
    4 [ nth-byte number>string ] map-with
    reverse "." join ;

: do-accept ( port sockaddr fd -- )
    [
        init-socket
        dup sockaddr-in-addr inet-ntoa
        swap sockaddr-in-port ntohs
    ] keep <client-stream> swap set-server-client ;

M: accept-task do-io-task
    io-task-port "sockaddr-in" <c-object>
    over port-handle over "sockaddr-in" heap-size <int> accept
    dup 0 >= [
        do-accept t
    ] [
        2drop defer-error
    ] if ;

M: accept-task task-container drop read-tasks get ;

: wait-to-accept ( server -- )
    [ swap <accept-task> add-io-task stop ] callcc0 drop ;

IN: network

: accept ( server -- client )
    #! Wait for a client connection.
    dup wait-to-accept  dup pending-error  server-client ;

! UDP

TUPLE: datagram packet addr port ;

: datagram-socket ( port -- fd )
    server-sockaddr SOCK_DGRAM [ bind-socket ] with-socket-fd ;

C: datagram ( port -- datagram )
    [ >r datagram-socket f <port> r> set-delegate ] keep
    datagram over set-port-type ;

IN: io-internals

: packet-size 65536 ; inline

: do-receive ( socket -- data addr port ? )
    packet-size <byte-array> [
        packet-size
        0
        "sockaddr-in" <c-object> [
            "sockaddr-in" heap-size <int>
            recvfrom
        ] keep
    ] keep pick -1 = [
        3drop f f f f
    ] [
        rot head swap
        dup sockaddr-in-addr inet-ntoa
        swap sockaddr-in-port ntohs
        t
    ] if ;

TUPLE: receive-task ;

C: receive-task ( stream -- task ) [ delegate>io-task ] keep ;

M: receive-task do-io-task
    io-task-port
    [ port-handle do-receive ] keep
    swap [
        [ set-datagram-port ] keep
        [ set-datagram-addr ] keep
        set-datagram-packet t
    ] [
        >r 3drop r> defer-error
    ] if ;

M: receive-task task-container drop read-tasks get ;

: wait-receive ( stream -- )
    [ swap <receive-task> add-io-task stop ] callcc0 drop ;

: do-send ( socket data host -- n )
    >r dup length 0 r> "sockaddr-in" heap-size sendto ;

TUPLE: send-task packet addr ;

C: send-task ( packet host stream -- task )
    [ delegate>io-task ] keep
    [ set-send-task-addr ] keep
    [ set-send-task-packet ] keep ;

M: send-task do-io-task
    [ io-task-port port-handle ] keep
    [ send-task-packet ] keep
    [ send-task-addr do-send ] keep
    swap 0 < [ defer-error ] [ drop t ] if ;

M: send-task task-container drop write-tasks get ;

: wait-send ( packet host stream -- )
    [ >r <send-task> r> swap add-io-task stop ] callcc0
    3drop ;

IN: network

: receive ( datagram -- packet host port )
    dup wait-receive dup pending-error
    dup datagram-packet over datagram-addr rot datagram-port ;

: send ( packet host port datagram -- )
    >r
    pick byte-array? [ "Bad parameter to send" throw ] unless
    client-sockaddr
    r>
    [ wait-send ] keep pending-error ;
