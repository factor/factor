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

BEGIN-STRUCT: stat
    FIELD: uint dev
    FIELD: uint ino
    FIELD: ushort mode
    FIELD: ushort nlink
    FIELD: uint uid
    FIELD: uint gid
    FIELD: uint rdev
    FIELD: ulong atime
    FIELD: ulong atimensec
    FIELD: ulong mtime
    FIELD: ulong mtimensec
    FIELD: ulong ctime
    FIELD: ulong ctimensec
    FIELD: off_t size
    FIELD: off_t blocks
    FIELD: uint blksize
    FIELD: uint flags
    FIELD: uint gen
    
    FIELD: uint padding
    FIELD: ulonglong padding
    FIELD: ulonglong padding
END-STRUCT

: S_IFMT OCT: 0170000 ; inline
: S_ISDIR ( m -- ? ) OCT: 0170000 bitand OCT: 0040000 = ; inline

: stat ( path stat -- n )
    "int" "libc" "stat" [ "char*" "stat*" ] alien-invoke ;

: opendir ( path -- dir* )
    "void*" "libc" "opendir" [ "char*" ] alien-invoke ;

BEGIN-STRUCT: dirent
    FIELD: uint fileno
    FIELD: ushort reclen
    FIELD: uchar type
    FIELD: uchar namlen
    FIELD: uchar256 name
END-STRUCT

: readdir ( dir* -- dirent* )
    "dirent*" "libc" "readdir" [ "void*" ] alien-invoke ;

: closedir ( dir* -- )
    "void" "libc" "closedir" [ "void*" ] alien-invoke ;

BEGIN-STRUCT: string-box
    FIELD: uchar256 value
END-STRUCT

: EINPROGRESS 36 ;

: errno ( -- n )
    "int" "libc" "errno" alien-global ;

: strerror ( n -- str )
    "char*" "libc" "strerror" [ "int" ] alien-invoke ;

: getcwd ( str len -- n )
    "int" "libc" "getcwd" [ "string-box*" "uint" ] alien-invoke ;

: O_RDONLY  HEX: 0000 ;
: O_WRONLY  HEX: 0001 ;
: O_RDWR    HEX: 0002 ;
: O_CREAT   HEX: 0200 ;
: O_TRUNC   HEX: 0400 ;

: open ( path flags prot -- fd )
    "int" "libc" "open" [ "char*" "int" "int" ] alien-invoke ;

: close ( fd -- )
    "void" "libc" "close" [ "int" ] alien-invoke ;

: F_SETFL 4 ; ! set file status flags
: O_NONBLOCK 4 ; ! no delay

: fcntl ( fd cmd key value -- n )
    "int" "libc" "fcntl" [ "int" "int" "int" "int" ] alien-invoke ;

: read ( fd buf nbytes -- n )
    "ssize_t" "libc" "read" [ "int" "ulong" "size_t" ] alien-invoke ;

: write ( fd buf nbytes -- n )
    "ssize_t" "libc" "write" [ "int" "ulong" "size_t" ] alien-invoke ;

: MSG_OOB HEX: 1 ;

: recv ( fd buf nbytes flags -- )
    "ssize_t" "libc" "read" [ "int" "ulong" "size_t" "int" ] alien-invoke ;

BEGIN-STRUCT: pollfd
    FIELD: int fd
    FIELD: short events
    FIELD: short revents
END-STRUCT

: POLLIN     HEX: 0001 ; ! any readable data available
: POLLPRI    HEX: 0002 ; ! OOB/Urgent readable data
: POLLOUT    HEX: 0004 ; ! file descriptor is writeable
: POLLRDNORM HEX: 0040 ; ! non-OOB/URG data available
: POLLWRNORM POLLOUT   ; ! no write type differentiation
: POLLRDBAND HEX: 0080 ; ! OOB/Urgent readable data
: POLLWRBAND HEX: 0100 ; ! OOB/Urgent data can be written

: read-events POLLIN POLLRDNORM bitor POLLRDBAND bitor ;
: write-events POLLOUT POLLWRNORM bitor POLLWRBAND bitor ;

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

: SOL_SOCKET HEX: ffff ; ! options for socket level
: SO_REUSEADDR HEX: 4 ; ! allow local address reuse
: INADDR_ANY 0 ;

: setsockopt ( s level optname optval optlen -- n )
    "int" "libc" "setsockopt" [ "int" "int" "int" "void*" "socklen_t" ] alien-invoke ;

: connect ( s name namelen -- n )
    "int" "libc" "connect" [ "int" "sockaddr-in*" "socklen_t" ] alien-invoke ;

: bind ( s sockaddr socklen -- n )
    "int" "libc" "bind" [ "int" "sockaddr-in*" "socklen_t" ] alien-invoke ;

: listen ( s backlog -- n )
    "int" "libc" "listen" [ "int" "int" ] alien-invoke ;

: accept ( s sockaddr socklen -- n )
    "int" "libc" "accept" [ "int" "sockaddr-in*" "socklen_t" ] alien-invoke ;

: inet-ntoa ( sockaddr -- string )
    "char*" "libc" "inet_ntoa" [ "in_addr_t" ] alien-invoke ;

: htonl ( n -- n )
    "uint" "libc" "htonl" [ "uint" ] alien-invoke ;

: htons ( n -- n )
    "ushort" "libc" "htons" [ "ushort" ] alien-invoke ;

: ntohl ( n -- n )
    "uint" "libc" "ntohl" [ "uint" ] alien-invoke ;

: ntohs ( n -- n )
    "ushort" "libc" "ntohs" [ "ushort" ] alien-invoke ;
