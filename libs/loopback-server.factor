
USING: kernel alien math namespaces errors io-internals unix-internals io generic ;

IN: loopback-server

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: INADDR_LOOPBACK   HEX: 7f000001 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: loopback-server-sockaddr ( port -- sockaddr )
init-sockaddr INADDR_LOOPBACK htonl over set-sockaddr-in-addr ;

: loopback-server-socket ( port -- fd )
    loopback-server-sockaddr [
        dup SOL_SOCKET SO_REUSEADDR sockopt
        swap dupd "sockaddr-in" heap-size bind
        dup 0 >= [ drop 1 listen ] [ nip ] if
    ] with-socket-fd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: loopback-server ;

C: loopback-server ( port -- server )
swap   { server f f } >tuple   swap
loopback-server-socket f <port> over set-delegate server over set-port-type
over set-delegate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-loopback-server ( port ident quot -- )
    >r >r <loopback-server> dup r> set r> swap [
        server-stream set
        [ server-loop ]
        [ server-stream get stream-close ] cleanup
    ] with-logging ; inline
