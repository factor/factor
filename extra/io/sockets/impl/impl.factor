! Copyright (C) 2007 Doug Coleman, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io.backend io.binary io.sockets
kernel math math.parser sequences splitting system
alien.c-types combinators namespaces alien ;
IN: io.sockets.impl

USE-IF: windows? windows.winsock
USE-IF: unix? unix

GENERIC: protocol-family ( addrspec -- af )

GENERIC: sockaddr-type ( addrspec -- type )

GENERIC: make-sockaddr ( addrspec -- sockaddr type )

GENERIC: parse-sockaddr ( sockaddr addrspec -- newaddrspec )

HOOK: addrinfo-error io-backend ( n -- )

! IPV4 and IPV6
GENERIC: address-size ( addrspec -- n )

GENERIC: inet-ntop ( data addrspec -- str )

GENERIC: inet-pton ( str addrspec -- data )


M: inet4 inet-ntop ( data addrspec -- str )
    drop 4 memory>string [ number>string ] { } map-as "." join ;

M: inet4 inet-pton ( str addrspec -- data )
    drop "." split [ string>number ] B{ } map-as ;

M: inet4 address-size drop 4 ;

M: inet4 protocol-family drop PF_INET ;

M: inet4 sockaddr-type drop "sockaddr-in" ;

M: inet4 make-sockaddr ( inet -- sockaddr type )
    "sockaddr-in" <c-object>
    AF_INET over set-sockaddr-in-family
    over inet4-port htons over set-sockaddr-in-port
    over inet4-host
    "0.0.0.0" or
    rot inet-pton *uint over set-sockaddr-in-addr
    "sockaddr-in" ;

M: inet4 parse-sockaddr
    >r dup sockaddr-in-addr <uint> r> inet-ntop
    swap sockaddr-in-port ntohs <inet4> ;


M: inet6 inet-ntop ( data addrspec -- str )
    drop 16 memory>string 2 <groups> [ be> >hex ] map ":" join ;

M: inet6 inet-pton ( str addrspec -- data )
    drop "::" split1
    [ [ ":" split [ hex> dup 0 ? ] map ] [ f ] if* ] 2apply
    2dup [ length ] 2apply + 8 swap - 0 <array> swap 3append
    [ 2 >be ] map concat >byte-array ;

M: inet6 address-size drop 16 ;

M: inet6 protocol-family drop PF_INET6 ;

M: inet6 sockaddr-type drop "sockaddr-in6" ;

M: inet6 make-sockaddr ( inet -- sockaddr type )
    "sockaddr-in6" <c-object>
    AF_INET6 over set-sockaddr-in6-family
    over inet6-port htons over set-sockaddr-in6-port
    over inet6-host "::" or
    rot inet-pton over set-sockaddr-in6-addr
    "sockaddr-in6" ;

M: inet6 parse-sockaddr
    >r dup sockaddr-in6-addr r> inet-ntop
    swap sockaddr-in6-port ntohs <inet6> ;

: addrspec-of-family ( af -- addrspec )
    {
        { [ dup AF_INET = ] [ T{ inet4 } ] }
        { [ dup AF_INET6 = ] [ T{ inet6 } ] }
        { [ dup AF_UNIX = ] [ T{ local } ] }
        { [ t ] [ f ] }
    } cond nip ;

M: f parse-sockaddr nip ;

: addrinfo>addrspec ( addrinfo -- addrspec )
    dup addrinfo-addr
    swap addrinfo-family addrspec-of-family
    parse-sockaddr ;

: addrspec, ( addrinfo -- )
    [ dup addrinfo>addrspec , addrinfo-next addrspec, ] when* ;

: parse-addrinfo-list ( addrinfo -- seq )
    [ addrspec, ] { } make [ ] subset ;

M: object resolve-host ( host serv passive? -- seq )
    >r dup integer? [ number>string ] when
    "addrinfo" <c-object>
    r> [ AI_PASSIVE over set-addrinfo-flags ] when
    PF_UNSPEC over set-addrinfo-family
    IPPROTO_TCP over set-addrinfo-protocol
    f <void*> [ getaddrinfo addrinfo-error ] keep *void*
    [ parse-addrinfo-list ] keep
    freeaddrinfo ;

M: object host-name ( -- name )
    256 <byte-array> dup dup length gethostname
    zero? [ "gethostname failed" throw ] unless
    alien>char-string ;

: >mac-address ( byte-array -- string )
    6 memory>string >byte-array
    [ >hex 2 48 pad-left ] { } map-as ":" join ;

