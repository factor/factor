! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix
USING: alien.syntax ;

! FreeBSD

: O_RDONLY  HEX: 0000 ; inline
: O_WRONLY  HEX: 0001 ; inline
: O_RDWR    HEX: 0002 ; inline
: O_APPEND  HEX: 0008 ; inline
: O_CREAT   HEX: 0200 ; inline
: O_TRUNC   HEX: 0400 ; inline
: O_EXCL    HEX: 0800 ; inline

: FD_SETSIZE 1024 ; inline

: SOL_SOCKET HEX: ffff ; inline
: SO_REUSEADDR HEX: 4 ; inline
: SO_OOBINLINE HEX: 100 ; inline
: SO_SNDTIMEO HEX: 1005 ; inline
: SO_RCVTIMEO HEX: 1006 ; inline

: F_SETFL 4 ; inline
: O_NONBLOCK 4 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" }
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "char*" "canonname" }
    { "void*" "addr" }
    { "addrinfo*" "next" } ;

C-STRUCT: sockaddr-in
    { "uchar" "len" }
    { "uchar" "family" }
    { "ushort" "port" }
    { "in_addr_t" "addr" }
    { "longlong" "unused" } ;

C-STRUCT: sockaddr-in6
    { "uchar" "len" }
    { "uchar" "family" }
    { "ushort" "port" }
    { "uint" "flowinfo" }
    { { "uchar" 16 } "addr" }
    { "uint" "scopeid" } ;

C-STRUCT: sockaddr-un
    { "uchar" "len" }
    { "uchar" "family" }
    { { "char" 104 } "path" } ;

: max-un-path 104 ; inline

: EINTR HEX: 4 ; inline
: EAGAIN HEX: 23 ; inline
: EINPROGRESS HEX: 24 ; inline

: SOCK_STREAM 1 ; inline
: SOCK_DGRAM 2 ; inline

: AF_UNSPEC 0 ; inline
: AF_UNIX 1 ; inline
: AF_INET 2 ; inline
: AF_INET6 30 ; inline

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
