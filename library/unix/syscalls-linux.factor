! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals
USING: alien ;

! Linux.

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0040 ;
: O_TRUNC   HEX: 0200 ;

: POLLIN     HEX: 0001 ;
: POLLPRI    HEX: 0002 ;
: POLLOUT    HEX: 0004 ;

: SOL_SOCKET 1 ;

: SO_REUSEADDR 2 ;
: SO_OOBINLINE 10 ;
: SO_SNDTIMEO HEX: 15 ;
: SO_RCVTIMEO HEX: 14 ;

: INADDR_ANY 0 ;

: F_SETFL 4 ;    ! set file status flags
: O_NONBLOCK 4 ; ! no delay

BEGIN-STRUCT: sockaddr-in
    FIELD: ushort family
    FIELD: ushort port
    FIELD: in_addr_t addr
    FIELD: longlong unused
END-STRUCT
