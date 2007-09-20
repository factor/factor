! Copyright (C) 2004, 2007 Slava Pestov, Ivan Tikhonov.
! See http://factorcode.org/license.txt for BSD license.

! We need to fiddle with the exact search order here, since
! unix::accept shadows streams::accept.
IN: io.unix.sockets
USING: alien alien.c-types generic io
kernel math namespaces io.nonblocking parser threads unix
sequences byte-arrays io.sockets io.binary io.unix.backend
io.streams.duplex io.sockets.impl math.parser continuations
libc combinators ;

: pending-init-error ( port -- )
    #! We close it here to avoid a resource leak; callers of
    #! <client> don't set up error handlers until after <client>
    #! returns (and if they did before, they wouldn't have
    #! anything to close!)
    dup port-error dup
    [ swap stream-close throw ] [ 2drop ] if ;

: socket-fd ( domain type -- socket )
    0 socket dup io-error dup init-handle ;

: sockopt ( fd level opt -- )
    1 <int> "int" heap-size setsockopt io-error ;

M: unix-io addrinfo-error ( n -- )
    dup zero? [ drop ] [ gai_strerror throw ] if ;

! Client sockets - TCP and Unix domain
: init-client-socket ( fd -- )
    SOL_SOCKET SO_OOBINLINE sockopt ;

TUPLE: connect-task ;

: <connect-task> ( port -- task ) connect-task <io-task> ;

M: connect-task do-io-task
    io-task-port dup port-handle f 0 write
    0 < [ defer-error ] [ drop t ] if ;

M: connect-task task-container drop write-tasks get-global ;

: wait-to-connect ( port -- )
    [ swap <connect-task> add-io-task stop ] callcc0 drop ;

M: unix-io (client) ( addrspec -- stream )
    dup make-sockaddr >r >r
    protocol-family SOCK_STREAM socket-fd
    dup r> r> heap-size connect
    zero? err_no EINPROGRESS = or [
        dup init-client-socket
        dup handle>duplex-stream
        dup duplex-stream-out
        dup wait-to-connect
        pending-init-error
    ] [
        dup close (io-error)
    ] if ;

! Server sockets - TCP and Unix domain
USE: unix

: init-server-socket ( fd -- )
    SOL_SOCKET SO_REUSEADDR sockopt ;

TUPLE: accept-task ;

: <accept-task> ( port -- task ) accept-task <io-task> ;

M: accept-task task-container drop read-tasks get ;

: accept-sockaddr ( port -- fd sockaddr )
    dup port-handle swap server-port-addr sockaddr-type
    dup <c-object> [ swap heap-size <int> accept ] keep ; inline

: do-accept ( port fd sockaddr -- )
    rot [
        server-port-addr parse-sockaddr
        swap dup handle>duplex-stream <client-stream>
    ] keep set-server-port-client ;

M: accept-task do-io-task
    io-task-port dup accept-sockaddr
    over 0 >= [ do-accept t ] [ 2drop defer-error ] if ;

: wait-to-accept ( server -- )
    [ swap <accept-task> add-io-task stop ] callcc0 drop ;

USE: io.sockets

: server-fd ( addrspec type -- fd )
    >r dup protocol-family r>  socket-fd
    dup init-server-socket
    dup rot make-sockaddr heap-size bind
    zero? [ dup close (io-error) ] unless ;

M: unix-io <server> ( addrspec -- stream )
    [
        SOCK_STREAM server-fd
        dup 10 listen zero? [ dup close (io-error) ] unless
        f <port>
    ] keep <server-port> ;

M: unix-io accept ( server -- client )
    #! Wait for a client connection.
    dup check-server-port
    dup wait-to-accept
    dup pending-error
    server-port-client ;

! Datagram sockets - UDP and Unix domain
M: unix-io <datagram>
    [ SOCK_DGRAM server-fd f <port> ] keep <datagram-port> ;

SYMBOL: receive-buffer

: packet-size 65536 ; inline

packet-size <byte-array> receive-buffer set-global

: setup-receive ( port -- s buffer len flags from fromlen )
    dup port-handle
    swap datagram-port-addr sockaddr-type
    dup <c-object> swap heap-size <int>
    >r >r receive-buffer get-global packet-size 0 r> r> ;

: do-receive ( s buffer len flags from fromlen -- sockaddr data )
    over >r recvfrom r>
    over -1 = [
        2drop f f
    ] [
        receive-buffer get-global
        rot head
    ] if ;

TUPLE: receive-task ;

: <receive-task> ( stream -- task ) receive-task <io-task> ;

M: receive-task do-io-task
    io-task-port
    dup setup-receive do-receive dup [
        pick set-datagram-port-packet
        over datagram-port-addr parse-sockaddr
        swap set-datagram-port-packet-addr
        t
    ] [
        2drop defer-error
    ] if ;

M: receive-task task-container drop read-tasks get ;

: wait-receive ( stream -- )
    [ swap <receive-task> add-io-task stop ] callcc0 drop ;

M: unix-io receive ( datagram -- packet addrspec )
    dup check-datagram-port
    dup wait-receive
    dup pending-error
    dup datagram-port-packet
    swap datagram-port-packet-addr ;

: do-send ( socket data sockaddr len -- n )
    >r >r dup length 0 r> r> sendto ;

TUPLE: send-task packet sockaddr len ;

: <send-task> ( packet sockaddr len port -- task )
    send-task <io-task> [
        {
            set-send-task-packet
            set-send-task-sockaddr
            set-send-task-len
        } set-slots
    ] keep ;

M: send-task do-io-task
    [ io-task-port port-handle ] keep
    [ send-task-packet ] keep
    [ send-task-sockaddr ] keep
    [ send-task-len do-send ] keep
    swap 0 < [ io-task-port defer-error ] [ drop t ] if ;

M: send-task task-container drop write-tasks get ;

: wait-send ( packet sockaddr len stream -- )
    [ >r <send-task> r> swap add-io-task stop ] callcc0
    2drop 2drop ;

M: unix-io send ( packet addrspec datagram -- )
    3dup check-datagram-send
    [ >r make-sockaddr heap-size r> wait-send ] keep
    pending-error ;

M: local protocol-family drop PF_UNIX ;

M: local sockaddr-type drop "sockaddr-un" ;

M: local make-sockaddr
    local-path
    dup length 1 + max-un-path > [ "Path too long" throw ] when
    "sockaddr-un" <c-object>
    AF_UNIX over set-sockaddr-un-family
    dup sockaddr-un-path rot string>char-alien dup length memcpy
   "sockaddr-un" ;

M: local parse-sockaddr
    drop
    sockaddr-un-path alien>char-string <local> ;
