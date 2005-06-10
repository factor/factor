! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals
USING: alien ;

! FreeBSD

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0200 ;
: O_TRUNC   HEX: 0400 ;
                        
: POLLIN     HEX: 0001 ;
: POLLPRI    HEX: 0002 ;
: POLLOUT    HEX: 0004 ;

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
