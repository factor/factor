! Copyright (C) 2007, 2008 Slava Pestov, Doug Coleman,
! Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: generic kernel io.backend namespaces continuations
sequences arrays io.encodings io.ports io.streams.duplex
io.encodings.ascii alien.strings io.binary accessors destructors
classes debugger byte-arrays system combinators parser
alien.c-types math.parser splitting math assocs inspector ;
IN: io.sockets

<< {
    { [ os windows? ] [ "windows.winsock" ] }
    { [ os unix? ] [ "unix" ] }
} cond use+ >>

! Addressing
GENERIC: protocol-family ( addrspec -- af )

GENERIC: sockaddr-type ( addrspec -- type )

GENERIC: make-sockaddr ( addrspec -- sockaddr )

GENERIC: address-size ( addrspec -- n )

GENERIC: inet-ntop ( data addrspec -- str )

GENERIC: inet-pton ( str addrspec -- data )

: make-sockaddr/size ( addrspec -- sockaddr size )
    [ make-sockaddr ] [ sockaddr-type heap-size ] bi ;

: empty-sockaddr/size ( addrspec -- sockaddr size )
    sockaddr-type [ <c-object> ] [ heap-size ] bi ;

GENERIC: parse-sockaddr ( sockaddr addrspec -- newaddrspec )

TUPLE: local path ;

: <local> ( path -- addrspec )
    normalize-path local boa ;

TUPLE: inet4 host port ;

C: <inet4> inet4

M: inet4 inet-ntop ( data addrspec -- str )
    drop 4 memory>byte-array [ number>string ] { } map-as "." join ;

ERROR: invalid-inet4 string reason ;

M: invalid-inet4 summary drop "Invalid IPv4 address" ;

M: inet4 inet-pton ( str addrspec -- data )
    drop
    [
        "." split dup length 4 = [
            "Must have four components" throw
        ] unless
        [
            string>number
            [ "Dotted component not a number" throw ] unless*
        ] B{ } map-as
    ] [ invalid-inet4 ] recover ;

M: inet4 address-size drop 4 ;

M: inet4 protocol-family drop PF_INET ;

M: inet4 sockaddr-type drop "sockaddr-in" c-type ;

M: inet4 make-sockaddr ( inet -- sockaddr )
    "sockaddr-in" <c-object>
    AF_INET over set-sockaddr-in-family
    over inet4-port htons over set-sockaddr-in-port
    over inet4-host
    "0.0.0.0" or
    rot inet-pton *uint over set-sockaddr-in-addr ;

<PRIVATE

SYMBOL: port-override

: (port) port-override get swap or ;

PRIVATE>

M: inet4 parse-sockaddr
    >r dup sockaddr-in-addr <uint> r> inet-ntop
    swap sockaddr-in-port ntohs (port) <inet4> ;

TUPLE: inet6 host port ;

C: <inet6> inet6

M: inet6 inet-ntop ( data addrspec -- str )
    drop 16 memory>byte-array 2 <groups> [ be> >hex ] map ":" join ;

ERROR: invalid-inet6 string reason ;

M: invalid-inet6 summary drop "Invalid IPv6 address" ;

<PRIVATE

: parse-inet6 ( string -- seq )
    dup empty? [ drop f ] [
        ":" split [
            hex> [ "Component not a number" throw ] unless*
        ] B{ } map-as
    ] if ;

: pad-inet6 ( string1 string2 -- seq )
    2dup [ length ] bi@ + 8 swap -
    dup 0 < [ "More than 8 components" throw ] when
    <byte-array> swap 3append ;

: inet6-bytes ( seq -- bytes )
    [ 2 >be ] { } map-as concat >byte-array ;

PRIVATE>

M: inet6 inet-pton ( str addrspec -- data )
    drop
    [
        "::" split1 [ parse-inet6 ] bi@ pad-inet6 inet6-bytes
    ] [ invalid-inet6 ] recover ;

M: inet6 address-size drop 16 ;

M: inet6 protocol-family drop PF_INET6 ;

M: inet6 sockaddr-type drop "sockaddr-in6" c-type ;

M: inet6 make-sockaddr ( inet -- sockaddr )
    "sockaddr-in6" <c-object>
    AF_INET6 over set-sockaddr-in6-family
    over inet6-port htons over set-sockaddr-in6-port
    over inet6-host "::" or
    rot inet-pton over set-sockaddr-in6-addr ;

M: inet6 parse-sockaddr
    >r dup sockaddr-in6-addr r> inet-ntop
    swap sockaddr-in6-port ntohs (port) <inet6> ;

: addrspec-of-family ( af -- addrspec )
    {
        { AF_INET [ T{ inet4 } ] }
        { AF_INET6 [ T{ inet6 } ] }
        { AF_UNIX [ T{ local } ] }
        [ drop f ]
    } case ;

M: f parse-sockaddr nip ;

GENERIC: (get-local-address) ( handle remote -- sockaddr )

: get-local-address ( handle remote -- local )
    [ (get-local-address) ] keep parse-sockaddr ;

GENERIC: establish-connection ( client-out remote -- )

GENERIC: ((client)) ( remote -- handle )

GENERIC: (client) ( remote -- client-in client-out local )

M: array (client) [ (client) 3array ] attempt-all first3 ;

M: object (client) ( remote -- client-in client-out local )
    [
        [ ((client)) ] keep
        [
            >r dup <ports> [ |dispose ] bi@ dup r>
            establish-connection
        ]
        [ get-local-address ]
        2bi
    ] with-destructors ;

: <client> ( remote encoding -- stream local )
    >r (client) -rot r> <encoder-duplex> swap ;

SYMBOL: local-address

: with-client ( addrspec encoding quot -- )
    >r <client> [ local-address set ] curry
    r> compose with-stream ; inline

TUPLE: server-port < port addr encoding ;

: check-server-port ( port -- port )
    dup check-disposed
    dup server-port? [ "Not a server port" throw ] unless ; inline

GENERIC: (server) ( addrspec -- handle )

: <server> ( addrspec encoding -- server )
    >r
    [ (server) ] keep
    [ drop server-port <port> ] [ get-local-address ] 2bi
    >>addr r> >>encoding ;

GENERIC: (accept) ( server addrspec -- handle )

: accept ( server -- client remote )
    [
        dup addr>>
        [ (accept) ] keep
        [ drop dup <ports> ] [ get-local-address ] 2bi
        -rot
    ] keep encoding>> <encoder-duplex> swap ;

TUPLE: datagram-port < port addr ;

HOOK: (datagram) io-backend ( addr -- datagram )

: <datagram> ( addr -- datagram )
    dup (datagram) datagram-port <port> swap >>addr ;

: check-datagram-port ( port -- port )
    dup check-disposed
    dup datagram-port? [ "Not a datagram port" throw ] unless ; inline

HOOK: (receive) io-backend ( datagram -- packet addrspec )

: receive ( datagram -- packet sockaddr )
    check-datagram-port
    [ (receive) ] [ addr>> ] bi parse-sockaddr ;

: check-datagram-send ( packet addrspec port -- packet addrspec port )
    check-datagram-port
    2dup addr>> [ class ] bi@ assert=
    pick class byte-array assert= ;

HOOK: (send) io-backend ( packet addrspec datagram -- )

: send ( packet addrspec datagram -- )
    check-datagram-send (send) ;

: addrinfo>addrspec ( addrinfo -- addrspec )
    [ addrinfo-addr ] [ addrinfo-family addrspec-of-family ] bi
    parse-sockaddr ;

: parse-addrinfo-list ( addrinfo -- seq )
    [ addrinfo-next ] follow
    [ addrinfo>addrspec ] map
    sift ;

: prepare-resolve-host ( host serv passive? -- host' serv' flags )
    #! If the port is a number, we resolve for 'http' then
    #! change it later. This is a workaround for a FreeBSD
    #! getaddrinfo() limitation -- on Windows, Linux and Mac,
    #! we can convert a number to a string and pass that as the
    #! service name, but on FreeBSD this gives us an unknown
    #! service error.
    >r
    dup integer? [ port-override set "http" ] when
    r> AI_PASSIVE 0 ? ;

HOOK: addrinfo-error io-backend ( n -- )

: resolve-host ( host serv passive? -- seq )
    [
        prepare-resolve-host
        "addrinfo" <c-object>
        [ set-addrinfo-flags ] keep
        PF_UNSPEC over set-addrinfo-family
        IPPROTO_TCP over set-addrinfo-protocol
        f <void*> [ getaddrinfo addrinfo-error ] keep *void*
        [ parse-addrinfo-list ] keep
        freeaddrinfo
    ] with-scope ;

: host-name ( -- string )
    256 <byte-array> dup dup length gethostname
    zero? [ "gethostname failed" throw ] unless
    ascii alien>string ;

TUPLE: inet host port ;

C: <inet> inet

: resolve-client-addr ( inet -- seq )
    [ host>> ] [ port>> ] bi f resolve-host ;

M: inet (client)
    resolve-client-addr (client) ;

ERROR: invalid-inet-server addrspec ;

M: invalid-inet-server summary
    drop "Cannot use <server> with <inet>; use <inet4> or <inet6> instead" ;

M: inet (server)
    invalid-inet-server ;
