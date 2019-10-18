! Copyright (C) 2006 Patrick Mauritz.
! See http://factorcode.org/license.txt for BSD license.
IN: unix-internals
USING: alien kernel kernel-internals ;

! Solaris.

: SOCK_STREAM 2 ;

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0100 ;
: O_TRUNC   HEX: 0200 ;

: SOL_SOCKET HEX: ffff ;

: FD_SETSIZE cell 4 = 1024 65536 ? ;

: SO_REUSEADDR 4 ;
: SO_OOBINLINE HEX: 0100 ;
: SO_SNDTIMEO HEX: 1005 ;
: SO_RCVTIMEO HEX: 1006 ;

: INADDR_ANY 0 ;

: F_SETFL 4 ;    ! set file status flags
: O_NONBLOCK HEX: 80 ; ! no delay

BEGIN-STRUCT: sockaddr-in
    FIELD: ushort family
    FIELD: ushort port
    FIELD: in_addr_t addr
    FIELD: longlong unused
END-STRUCT

: EINTR HEX: 4 ;
: EAGAIN 11 ;
: EINPROGRESS 150 ;
