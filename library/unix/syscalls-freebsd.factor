! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix-internals
USING: alien ;

! FreeBSD

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0200 ;
: O_TRUNC   HEX: 0400 ;
                        
: FD_SETSIZE 1024 ;

: SOL_SOCKET HEX: ffff ;
: SO_REUSEADDR HEX: 4 ;
: SO_OOBINLINE HEX: 100 ;
: SO_SNDTIMEO HEX: 1005 ;
: SO_RCVTIMEO HEX: 1006 ;

: INADDR_ANY 0 ;

: F_SETFL 4 ;
: O_NONBLOCK 4 ;

BEGIN-STRUCT: sockaddr-in
    FIELD: uchar len
    FIELD: uchar family
    FIELD: ushort port
    FIELD: in_addr_t addr
    FIELD: longlong unused
END-STRUCT

: EINTR HEX: 4 ;
: EAGAIN HEX: 23 ;
: EINPROGRESS HEX: 24 ;

: AF_INET 2 ;
: PF_INET AF_INET ;
: SOCK_STREAM 1 ;
