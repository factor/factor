! Copyright (C) 2006 Patrick Mauritz.
! See http://factorcode.org/license.txt for BSD license.
IN: unix
USING: alien.syntax system kernel ;

TYPEDEF: ulong off_t

! Solaris.

: O_RDONLY  HEX: 0000 ; inline
: O_WRONLY  HEX: 0001 ; inline
: O_RDWR    HEX: 0002 ; inline
: O_APPEND  HEX: 0008 ; inline
: O_CREAT   HEX: 0100 ; inline
: O_TRUNC   HEX: 0200 ; inline

: SEEK_END 2 ; inline

: SOL_SOCKET HEX: ffff ; inline

: FD_SETSIZE cell 4 = 1024 65536 ? ; inline

: SO_REUSEADDR 4 ; inline
: SO_OOBINLINE HEX: 0100 ; inline
: SO_SNDTIMEO HEX: 1005 ; inline
: SO_RCVTIMEO HEX: 1006 ; inline

: F_SETFL 4 ;    ! set file status flags
: O_NONBLOCK HEX: 80 ; ! no delay

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" }
    { "int" "socktype" }
    { "int" "protocol" }
! #ifdef __sparcv9
!         int _ai_pad;            
! #endif
    { "int" "addrlen" }
    { "char*" "canonname" }
    { "void*" "addr" }
    { "void*" "next" } ;

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

: max-un-path 108 ;

C-STRUCT: sockaddr-un
    { "ushort" "family" }
    { { "char" max-un-path } "path" } ;

: EINTR 4 ; inline
: EAGAIN 11 ; inline
: EINPROGRESS 150 ; inline

: SOCK_STREAM 2 ; inline
: SOCK_DGRAM 1 ; inline

: AF_UNSPEC 0 ; inline
: AF_UNIX 1 ; inline
: AF_INET 2 ; inline
: AF_INET6 26 ; inline

: PF_UNSPEC AF_UNSPEC ; inline
: PF_UNIX AF_UNIX ; inline
: PF_INET AF_INET ; inline
: PF_INET6 AF_INET6 ; inline

: IPPROTO_TCP 6 ; inline
: IPPROTO_UDP 17 ; inline

: AI_PASSIVE 8 ; inline
