! Copyright (C) 2007, 2011 Slava Pestov, Doug Coleman,
! Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
byte-arrays classes classes.struct combinators
combinators.short-circuit continuations destructors fry
grouping init io.backend io.binary io.encodings.ascii
io.encodings.binary io.pathnames io.ports io.streams.duplex
kernel locals math math.parser memoize namespaces present
sequences sequences.private splitting strings summary system
vocabs vocabs.parser ;
IN: io.sockets

<< {
    { [ os windows? ] [ "windows.winsock" ] }
    { [ os unix? ] [ "unix.ffi" ] }
} cond use-vocab >>

GENERIC# with-port 1 ( addrspec port -- addrspec )

! Addressing
<PRIVATE

GENERIC: protocol ( addrspec -- n )

GENERIC: protocol-family ( addrspec -- af )

GENERIC: sockaddr-size ( addrspec -- n )

GENERIC: make-sockaddr ( addrspec -- sockaddr )

GENERIC: empty-sockaddr ( addrspec -- sockaddr )

GENERIC: address-size ( addrspec -- n )

GENERIC: inet-ntop ( data addrspec -- str )

GENERIC: inet-pton ( str addrspec -- data )

: make-sockaddr/size ( addrspec -- sockaddr size )
    [ make-sockaddr ] [ sockaddr-size ] bi ;

: empty-sockaddr/size ( addrspec -- sockaddr size )
    [ empty-sockaddr ] [ sockaddr-size ] bi ;

GENERIC: parse-sockaddr ( sockaddr addrspec -- newaddrspec )

M: f parse-sockaddr nip ;

HOOK: sockaddr-of-family os ( alien af -- sockaddr )

HOOK: addrspec-of-family os ( af -- addrspec )

PRIVATE>

TUPLE: local { path string read-only } ;

: <local> ( path -- addrspec )
    absolute-path local boa ;

M: local present path>> "Unix domain socket: " prepend ;

M: local protocol drop 0 ;

SLOT: port

TUPLE: ipv4 { host maybe{ string } read-only } ;

<PRIVATE

ERROR: invalid-ipv4 string reason ;

M: invalid-ipv4 summary drop "Invalid IPv4 address" ;

ERROR: malformed-ipv4 sequence ;

ERROR: bad-ipv4-component string ;

: parse-ipv4 ( string -- seq )
    [ f ] [
        "." split dup length 4 = [ malformed-ipv4 ] unless
        [ dup string>number [ ] [ bad-ipv4-component ] ?if ] B{ } map-as
    ] if-empty ;

: check-ipv4 ( string -- )
    [ parse-ipv4 drop ] [ invalid-ipv4 ] recover ;

PRIVATE>

: <ipv4> ( host -- ipv4 ) dup check-ipv4 ipv4 boa ;

M: ipv4 inet-ntop ( data addrspec -- str )
    drop 4 memory>byte-array [ number>string ] { } map-as "." join ;

M: ipv4 inet-pton ( str addrspec -- data )
    drop [ parse-ipv4 ] [ invalid-ipv4 ] recover ;

M: ipv4 address-size drop 4 ;

M: ipv4 protocol-family drop PF_INET ;

M: ipv4 sockaddr-size drop sockaddr-in heap-size ;

M: ipv4 empty-sockaddr drop sockaddr-in <struct> ;

M: ipv4 make-sockaddr ( inet -- sockaddr )
    sockaddr-in <struct>
        AF_INET >>family
        swap
        [ port>> htons >>port ]
        [ host>> "0.0.0.0" or ]
        [ inet-pton uint deref >>addr ] tri ;

M: ipv4 parse-sockaddr ( sockaddr-in addrspec -- newaddrspec )
    [ addr>> uint <ref> ] dip inet-ntop <ipv4> ;

TUPLE: inet4 < ipv4 { port integer read-only } ;

: <inet4> ( host port -- inet4 )
    over check-ipv4 inet4 boa ;

: <random-local-inet4> ( -- inet4 ) f 0 <inet4> ;

M: ipv4 with-port [ host>> ] dip <inet4> ;

M: inet4 parse-sockaddr ( sockaddr-in addrspec -- newaddrspec )
    [ call-next-method ] [ drop port>> ntohs ] 2bi with-port ;

M: inet4 present
    [ host>> ] [ port>> number>string ] bi ":" glue ;

M: inet4 protocol drop 0 ;

TUPLE: ipv6
{ host maybe{ string } read-only }
{ scope-id integer read-only } ;

<PRIVATE

ERROR: invalid-ipv6 host reason ;

M: invalid-ipv6 summary drop "Invalid IPv6 address" ;

ERROR: bad-ipv6-component obj ;

ERROR: bad-ipv4-embedded-prefix obj ;

ERROR: more-than-8-components ;

: parse-ipv6-component ( seq -- seq' )
    [ dup hex> [ nip ] [ bad-ipv6-component ] if* ] { } map-as ;

: parse-ipv6 ( string -- seq )
    [ f ] [
        ":" split CHAR: . over last member? [
            unclip-last
            [ parse-ipv6-component ] [ parse-ipv4 ] bi* append
        ] [
            parse-ipv6-component
        ] if
    ] if-empty ;

: check-ipv6 ( string -- )
    [ "::" split1 [ parse-ipv6 ] bi@ 2drop ] [ invalid-ipv6 ] recover ;

PRIVATE>

: <ipv6> ( host -- ipv6 ) dup check-ipv6 0 ipv6 boa ;

M: ipv6 inet-ntop ( data addrspec -- str )
    drop 16 memory>byte-array 2 <groups> [ be> >hex ] map ":" join ;

<PRIVATE

: pad-ipv6 ( string1 string2 -- seq )
    2dup [ length ] bi@ + 8 swap -
    dup 0 < [ more-than-8-components ] when
    <byte-array> glue ;

: ipv6-bytes ( seq -- bytes )
    [ 2 >be ] { } map-as B{ } concat-as ;

PRIVATE>

M: ipv6 inet-pton ( str addrspec -- data )
    drop
    [ "::" split1 [ parse-ipv6 ] bi@ pad-ipv6 ipv6-bytes ]
    [ invalid-ipv6 ]
    recover ;

M: ipv6 address-size drop 16 ;

M: ipv6 protocol-family drop PF_INET6 ;

M: ipv6 sockaddr-size drop sockaddr-in6 heap-size ;

M: ipv6 empty-sockaddr drop sockaddr-in6 <struct> ;

M: ipv6 make-sockaddr ( inet -- sockaddr )
    sockaddr-in6 <struct>
        AF_INET6 >>family
        swap
        [ port>> htons >>port ]
        [ [ host>> "::" or ] keep inet-pton >>addr ]
        [ scope-id>> >>scopeid ]
        tri ;

M: ipv6 parse-sockaddr
    [ [ addr>> ] dip inet-ntop ] [ drop scopeid>> ] 2bi
    ipv6 boa ;

M: ipv6 present
    [ host>> ] [ scope-id>> ] bi
    [ number>string "%" glue ] unless-zero ;

TUPLE: inet6 < ipv6 { port integer read-only } ;

: <inet6> ( host port -- inet6 )
    [ dup check-ipv6 0 ] dip inet6 boa ;

M: ipv6 with-port
    [ [ host>> ] [ scope-id>> ] bi ] dip
    inet6 boa ;

M: inet6 parse-sockaddr
    [ call-next-method ] [ drop port>> ntohs ] 2bi with-port ;

M: inet6 present
    [ call-next-method ] [ port>> number>string ] bi ":" glue ;

M: inet6 protocol drop 0 ;

ERROR: addrinfo-error n string ;

<PRIVATE

GENERIC: (get-local-address) ( handle remote -- sockaddr )

: get-local-address ( handle remote -- local )
    [ (get-local-address) ] keep parse-sockaddr ;

GENERIC: (get-remote-address) ( handle remote -- sockaddr )

: get-remote-address ( handle local -- remote )
    [ (get-remote-address) ] keep parse-sockaddr ;

: <ports> ( handle -- input-port output-port )
    [
        [ <input-port> |dispose ] [ <output-port> |dispose ] bi
    ] with-destructors ;

SYMBOL: bind-local-address

GENERIC: establish-connection ( client-out remote -- )

GENERIC: ((client)) ( remote -- handle )

GENERIC: (client) ( remote -- client-in client-out local )

M: array (client) [ (client) 3array ] attempt-all first3 ;

M: object (client) ( remote -- client-in client-out local )
    [
        [ ((client)) ] keep
        [
            [ <ports> [ |dispose ] bi@ dup ] dip
            establish-connection
        ]
        [ get-local-address ]
        2bi
    ] with-destructors ;

TUPLE: server-port < port addr encoding ;

GENERIC: (server) ( addrspec -- handle )

GENERIC: (accept) ( server addrspec -- handle sockaddr )

TUPLE: datagram-port < port addr ;

HOOK: (datagram) io-backend ( addr -- datagram )

TUPLE: raw-port < port addr ;

HOOK: (raw) io-backend ( addr -- raw )

HOOK: (broadcast) io-backend ( datagram -- datagram )

HOOK: (receive-unsafe) io-backend ( n buf datagram -- count addrspec )

ERROR: invalid-port object ;

: check-port ( bytes addrspec port -- bytes addrspec port )
    2dup addr>> [ class-of ] bi@ assert=
    pick class-of byte-array assert= ;

: check-connectionless-port ( port -- port )
    dup { [ datagram-port? ] [ raw-port? ] } 1|| [ invalid-port ] unless ;

: check-send ( bytes addrspec port -- bytes addrspec port )
    check-connectionless-port check-disposed check-port ;

: check-receive ( port -- port )
    check-connectionless-port check-disposed ;

HOOK: (send) io-backend ( bytes addrspec datagram -- )

: addrinfo>addrspec ( addrinfo -- addrspec )
    [ [ addr>> ] [ family>> ] bi sockaddr-of-family ]
    [ family>> addrspec-of-family ] bi
    parse-sockaddr ;

: parse-addrinfo-list ( addrinfo -- seq )
    [ next>> ] follow
    [ addrinfo>addrspec ] map
    sift ;

HOOK: addrinfo-error-string io-backend ( n -- string )

: prepare-addrinfo ( -- addrinfo )
    addrinfo <struct>
        PF_UNSPEC >>family
        IPPROTO_TCP >>protocol ;

PRIVATE>

: <client> ( remote encoding -- stream local )
    [ (client) ] dip swap [ <encoder-duplex> ] dip ;

SYMBOL: local-address

SYMBOL: remote-address

: with-client ( remote encoding quot -- )
    [
        [
            over remote-address set
            <client> local-address set
        ] dip with-stream
    ] with-scope ; inline

: <server> ( addrspec encoding -- server )
    [
        [ (server) ] keep
        [ drop server-port <port> ] [ get-local-address ] 2bi
        >>addr
    ] dip >>encoding ;

: accept ( server -- client remote )
    [
        dup addr>>
        [ (accept) ] keep
        parse-sockaddr swap
        <ports>
    ] [ encoding>> ] bi <encoder-duplex> swap ;

: <datagram> ( addrspec -- datagram )
    [
        [ (datagram) |dispose ] keep
        [ drop datagram-port <port> ] [ get-local-address ] 2bi
        >>addr
    ] with-destructors ;

: <raw> ( addrspec -- datagram )
    [
        [ (raw) |dispose ] keep
        [ drop raw-port <port> ] [ get-local-address ] 2bi
        >>addr
    ] with-destructors ;

: <broadcast> ( addrspec -- datagram )
    <datagram> (broadcast) ;

: receive-unsafe ( n buf datagram -- count addrspec )
    check-receive
    [ (receive-unsafe) ] [ addr>> ] bi parse-sockaddr ; inline

CONSTANT: datagram-size 65536

:: receive ( datagram -- bytes addrspec )
    datagram-size (byte-array) :> buf
    datagram-size buf datagram
    receive-unsafe :> ( count addrspec )
    count buf resize addrspec ; inline

:: receive-into ( buf datagram -- buf-slice addrspec )
    buf length :> n
    n buf datagram receive-unsafe :> ( count addrspec )
    buf count head-slice addrspec ; inline

: send ( bytes addrspec datagram -- )
    check-send (send) ; inline

: <random-local-datagram> ( -- datagram )
    <random-local-inet4> <datagram> ;

: <random-local-broadcast> ( -- datagram )
    <random-local-inet4> <broadcast> ;

: with-random-local-datagram ( quot -- )
    [ <random-local-datagram> ] dip with-disposal ; inline

: with-random-local-broadcast ( quot -- )
    [ <random-local-broadcast> ] dip with-disposal ; inline

: send-once ( bytes addrspec -- )
    [ send ] with-random-local-datagram ;

: broadcast-once ( bytes addrspec -- )
    [ send ] with-random-local-broadcast ;

MEMO: ipv6-supported? ( -- ? )
    [ "::1" 0 <inet6> binary <server> dispose t ] [ drop f ] recover ;

[ \ ipv6-supported? reset-memoized ]
"io.sockets:ipv6-supported?" add-startup-hook

GENERIC: resolve-host ( addrspec -- seq )

HOOK: resolve-localhost os ( -- obj )

TUPLE: hostname { host maybe{ string } read-only } ;

TUPLE: inet < hostname port ;

M: inet present
    [ host>> ] [ port>> number>string ] bi ":" glue ;

C: <inet> inet

M: string resolve-host
    f prepare-addrinfo f void* <ref> [
        getaddrinfo [
            dup addrinfo-error-string addrinfo-error
        ] unless-zero
    ] keep void* deref addrinfo memory>struct
    [ parse-addrinfo-list ] keep freeaddrinfo ;

M: string with-port <inet> ;

M: hostname resolve-host
    host>> resolve-host ;

M: hostname with-port
    [ host>> ] dip <inet> ;

M: inet resolve-host
    [ call-next-method ] [ port>> ] bi '[ _ with-port ] map ;

M: inet4 resolve-host 1array ;

M: inet6 resolve-host 1array ;

M: local resolve-host 1array ;

M: f resolve-host
    drop resolve-localhost ;

M: object resolve-localhost
    ipv6-supported?
    { T{ ipv4 f "0.0.0.0" } T{ ipv6 f "::" } }
    { T{ ipv4 f "0.0.0.0" } }
    ? ;

HOOK: host-name os ( -- string )

M: inet (client) resolve-host (client) ;

ERROR: invalid-inet-server addrspec ;

M: invalid-inet-server summary
    drop "Cannot use <server> with <inet>; use <inet4> or <inet6> instead" ;

M: inet (server)
    invalid-inet-server ;

ERROR: invalid-local-address addrspec ;

M: invalid-local-address summary
    drop "Cannot use with-local-address with <inet>; use <inet4> or <inet6> instead" ;

: with-local-address ( addr quot -- )
    [
        [ ] [ inet4? ] [ inet6? ] tri or
        [ bind-local-address ]
        [ invalid-local-address ] if
    ] dip with-variable ; inline

: protocol-port ( protocol -- port )
    [ f getservbyname [ port>> htons ] [ f ] if* ] [ f ] if* ;

{
    { [ os unix? ] [ "io.sockets.unix" require ] }
    { [ os windows? ] [ "io.sockets.windows" require ] }
} cond
