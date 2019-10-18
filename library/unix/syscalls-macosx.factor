! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals

! Mac OS X

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0200 ;
: O_TRUNC   HEX: 0400 ;

: POLLIN     HEX: 0001 ; ! any readable data available
: POLLPRI    HEX: 0002 ; ! OOB/Urgent readable data
: POLLOUT    HEX: 0004 ; ! file descriptor is writeable

: SOL_SOCKET HEX: ffff ; ! options for socket level
: SO_REUSEADDR HEX: 4 ; ! allow local address reuse
: INADDR_ANY 0 ;

: F_SETFL 4 ;    ! set file status flags
: O_NONBLOCK 4 ; ! no delay
