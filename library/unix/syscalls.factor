! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: unix-internals
USING: alien errors kernel math namespaces ;

! Alien wrappers for various Unix libc functions.

ALIAS: ulonglong off_t
ALIAS: long ssize_t
ALIAS: ulong size_t
ALIAS: uint socklen_t
ALIAS: uint in_addr_t

: EINPROGRESS 36 ;

: errno ( -- n )
    "int" f "factor_errno" [ ] alien-invoke ;

: strerror ( n -- str )
    "char*" "libc" "strerror" [ "int" ] alien-invoke ;

: open ( path flags prot -- fd )
    "int" "libc" "open" [ "char*" "int" "int" ] alien-invoke ;

: close ( fd -- )
    "void" "libc" "close" [ "int" ] alien-invoke ;

: fcntl ( fd cmd arg -- n )
    "int" "libc" "fcntl" [ "int" "int" "int" ] alien-invoke ;

: read ( fd buf nbytes -- n )
    "ssize_t" "libc" "read" [ "int" "ulong" "size_t" ] alien-invoke ;

: write ( fd buf nbytes -- n )
    "ssize_t" "libc" "write" [ "int" "ulong" "size_t" ] alien-invoke ;

BEGIN-STRUCT: pollfd
    FIELD: int fd
    FIELD: short events
    FIELD: short revents
END-STRUCT

: poll ( pollfds nfds timeout -- n )
    "int" "libc" "poll" [ "pollfd*" "uint" "int" ] alien-invoke ;

BEGIN-STRUCT: uint*
    FIELD: uint s
END-STRUCT

BEGIN-STRUCT: VOID* ( ugly )
    FIELD: void* s
END-STRUCT

BEGIN-STRUCT: hostent
    FIELD: char* name
    FIELD: VOID** aliases
    FIELD: int addrtype
    FIELD: int length
    FIELD: VOID** addr-list
END-STRUCT

: hostent-addr hostent-addr-list VOID*-s uint*-s ;

: gethostbyname ( name -- hostent )
    "hostent*" "libc" "gethostbyname" [ "char*" ] alien-invoke ;

BEGIN-STRUCT: sockaddr-in
    FIELD: uchar len
    FIELD: uchar family
    FIELD: ushort port
    FIELD: in_addr_t addr
    FIELD: longlong unused
END-STRUCT

: AF_INET 2 ;
: PF_INET AF_INET ;
: SOCK_STREAM 1 ;

: socket ( domain type protocol -- n )
    "int" "libc" "socket" [ "int" "int" "int" ] alien-invoke ;

: setsockopt ( s level optname optval optlen -- n )
    "int" "libc" "setsockopt" [ "int" "int" "int" "void*" "socklen_t" ] alien-invoke ;

: connect ( s name namelen -- n )
    "int" "libc" "connect" [ "int" "sockaddr-in*" "socklen_t" ] alien-invoke ;

: bind ( s sockaddr socklen -- n )
    "int" "libc" "bind" [ "int" "sockaddr-in*" "socklen_t" ] alien-invoke ;

: listen ( s backlog -- n )
    "int" "libc" "listen" [ "int" "int" ] alien-invoke ;

: accept ( s sockaddr socklen -- n )
    "int" "libc" "accept" [ "int" "sockaddr-in*" "int-box*" ] alien-invoke ;

: htonl ( n -- n )
    "uint" "libc" "htonl" [ "uint" ] alien-invoke ;

: htons ( n -- n )
    "ushort" "libc" "htons" [ "ushort" ] alien-invoke ;

: ntohl ( n -- n )
    "uint" "libc" "ntohl" [ "uint" ] alien-invoke ;

: ntohs ( n -- n )
    "ushort" "libc" "ntohs" [ "ushort" ] alien-invoke ;
