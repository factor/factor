! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals

! Mac OS X

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
: SO_OOBINLINE HEX: ff ;

: INADDR_ANY 0 ;

: F_SETFL 4 ;
: O_NONBLOCK 4 ;
