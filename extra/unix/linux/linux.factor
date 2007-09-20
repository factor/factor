! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix
USING: alien.syntax ;

TYPEDEF: ulong off_t

! Linux.

: O_RDONLY  HEX: 0000 ; inline
: O_WRONLY  HEX: 0001 ; inline
: O_RDWR    HEX: 0002 ; inline
: O_CREAT   HEX: 0040 ; inline
: O_EXCL    HEX: 0080 ; inline
: O_TRUNC   HEX: 0200 ; inline
: O_APPEND  HEX: 0400 ; inline

: SOL_SOCKET 1 ; inline

: FD_SETSIZE 1024 ; inline

: SO_REUSEADDR 2 ; inline
: SO_OOBINLINE 10 ; inline
: SO_SNDTIMEO HEX: 15 ; inline
: SO_RCVTIMEO HEX: 14 ; inline

: F_SETFL 4 ; inline
: O_NONBLOCK HEX: 800 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" }
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "void*" "addr" }
    { "char*" "canonname" }
    { "addrinfo*" "next" } ;

C-STRUCT: sockaddr-in
    { "ushort" "family" }
    { "ushort" "port" }
    { "in_addr_t" "addr" }
    { "longlong" "unused" } ;

C-STRUCT: sockaddr-in6
    { "ushort" "family" }
    { "ushort" "port" }
    { "uint" "flowinfo" }
    { { "uchar" 16 } "addr" }
    { "uint" "scopeid" } ;

: max-un-path 108 ; inline

C-STRUCT: sockaddr-un
    { "ushort" "family" }
    { { "char" max-un-path } "path" } ;

: EINTR HEX: 4 ; inline
: EAGAIN HEX: b ; inline
: EINPROGRESS HEX: 73 ; inline

: SOCK_STREAM 1 ; inline
: SOCK_DGRAM 2 ; inline

: AF_UNSPEC 0 ; inline
: AF_UNIX 1 ; inline
: AF_INET 2 ; inline
: AF_INET6 10 ; inline

: PF_UNSPEC AF_UNSPEC ; inline
: PF_UNIX AF_UNIX ; inline
: PF_INET AF_INET ; inline
: PF_INET6 AF_INET6 ; inline

: IPPROTO_TCP 6 ; inline
: IPPROTO_UDP 17 ; inline

: AI_PASSIVE 1 ; inline

: SEEK_SET 0 ; inline
: SEEK_CUR 1 ; inline
: SEEK_END 2 ; inline
