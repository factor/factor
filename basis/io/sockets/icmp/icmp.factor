! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators io.sockets
io.sockets.private kernel sequences system
vocabs.parser ;

IN: io.sockets.icmp

<< {
    { [ os windows? ] [ "windows.winsock" ] }
    { [ os unix? ] [ "unix.ffi" ] }
} cond use-vocab >>

<PRIVATE

MEMO: IPPROTO_ICMP4 ( -- protocol )
    "icmp" getprotobyname proto>> ;

MEMO: IPPROTO_ICMP6 ( -- protocol )
    "ipv6-icmp" getprotobyname proto>> ;

GENERIC: with-icmp ( addrspec -- addrspec )

PRIVATE>


TUPLE: icmp4 < ipv4 ;

C: <icmp4> icmp4

M: ipv4 with-icmp host>> <icmp4> ;

M: icmp4 protocol drop IPPROTO_ICMP4 ;

M: icmp4 port>> drop 0 ;

M: icmp4 parse-sockaddr call-next-method with-icmp ;

M: icmp4 resolve-host 1array ;


TUPLE: icmp6 < ipv6 ;

: <icmp6> ( host -- icmp6 ) 0 icmp6 boa ;

M: ipv6 with-icmp host>> <icmp6> ;

M: icmp6 protocol drop IPPROTO_ICMP6 ;

M: icmp6 port>> drop 0 ;

M: icmp6 parse-sockaddr call-next-method with-icmp ;

M: icmp6 resolve-host 1array ;


TUPLE: icmp < hostname ;

C: <icmp> icmp

M: icmp resolve-host call-next-method [ with-icmp ] map ;
