! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals
USING: alien errors kernel math namespaces ;

! Alien wrappers for various Unix libc functions.

LIBRARY: factor
FUNCTION: int err_no ( ) ;

LIBRARY: libc
FUNCTION: char* strerror ( int errno ) ;
FUNCTION: int open ( char* path, int flags, int prot ) ;
FUNCTION: void close ( int fd ) ;
FUNCTION: int fcntl ( int fd, int cmd, int arg ) ;
FUNCTION: ssize_t read ( int fd, ulong buf, size_t nbytes ) ;
FUNCTION: ssize_t write ( int fd, ulong buf, size_t nbytes ) ;

BEGIN-STRUCT: timeval
    FIELD: long sec
    FIELD: long usec
END-STRUCT

: make-timeval ( ms -- timeval )
    dup -1 = [
        drop f
    ] [
        1000 /mod 1000 *
        "timeval" <c-object>
        [ set-timeval-usec ] keep
        [ set-timeval-sec ] keep
    ] if ;

FUNCTION: int select ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout ) ;

BEGIN-STRUCT: hostent
    FIELD: char* name
    FIELD: void* aliases
    FIELD: int addrtype
    FIELD: int length
    FIELD: void* addr-list
END-STRUCT

: hostent-addr hostent-addr-list *void* *uint ;

: gethostbyname ( name -- hostent )
    "hostent*" "libc" "gethostbyname" [ "char*" ] alien-invoke ;

: AF_INET 2 ;
: PF_INET AF_INET ;
: SOCK_STREAM 1 ;

FUNCTION: int socket ( int domain, int type, int protocol ) ;
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen ) ;
FUNCTION: int connect ( int s, sockaddr-in* name, socklen_t namelen ) ;
FUNCTION: int bind ( int s, sockaddr-in* name, socklen_t namelen ) ;
FUNCTION: int listen ( int s, int backlog ) ;
FUNCTION: int accept ( int s, sockaddr-in* sockaddr, socklen_t* socklen ) ;
FUNCTION: uint htonl ( uint n ) ;
FUNCTION: ushort htons ( ushort n ) ;
FUNCTION: uint ntohl ( uint n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;
