! Copyright (C) 2006 Patrick Mauritz.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax system kernel layouts ;
IN: unix

! Solaris.

CONSTANT: O_RDONLY  HEX: 0000
CONSTANT: O_WRONLY  HEX: 0001
CONSTANT: O_RDWR    HEX: 0002
CONSTANT: O_APPEND  HEX: 0008
CONSTANT: O_CREAT   HEX: 0100
CONSTANT: O_TRUNC   HEX: 0200

CONSTANT: SEEK_END 2

CONSTANT: SOL_SOCKET HEX: ffff

: FD_SETSIZE ( -- n ) cell 4 = 1024 65536 ? ;

CONSTANT: SO_REUSEADDR 4
CONSTANT: SO_OOBINLINE HEX: 0100
CONSTANT: SO_SNDTIMEO HEX: 1005
CONSTANT: SO_RCVTIMEO HEX: 1006

CONSTANT: F_SETFL 4    ! set file status flags
CONSTANT: O_NONBLOCK HEX: 80 ! no delay

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
! #ifdef __sparcv9
!         int _ai_pad;            
! #endif
    { addrlen int }
    { canonname char* }
    { addr void* }
    { next void* } ;

STRUCT: sockaddr-in
    { family ushort }
    { port ushort }
    { addr in_addr_t }
    { unused longlong } ;

STRUCT: sockaddr-in6
    { family ushort }
    { port ushort }
    { flowinfo uint }
    { addr uchar[16] }
    { scopeid uint } ;

: max-un-path 108 ;

STRUCT: sockaddr-un
    { family ushort }
    { path { "char" max-un-path } } ;

CONSTANT: EINTR 4
CONSTANT: EAGAIN 11
CONSTANT: EINPROGRESS 150

CONSTANT: SOCK_STREAM 2
CONSTANT: SOCK_DGRAM 1

CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2
CONSTANT: AF_INET6 26

ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET
ALIAS: PF_INET6 AF_INET6

CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17

CONSTANT: AI_PASSIVE 8
