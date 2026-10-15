USING: alien.c-types alien.data alien.syntax kernel math system unix.types ;
IN: unix.ffi

LIBRARY: haiku-network
C-LIBRARY: haiku-network { { haiku "libnetwork.so" } }

FUNCTION: int accept ( int s, void* sockaddr, socklen_t* socklen )
FUNCTION: int bind ( int s, void* name, socklen_t namelen )
FUNCTION: int connect ( int s, void* name, socklen_t namelen )
FUNCTION: void freeaddrinfo ( addrinfo* ai )
FUNCTION: c-string gai_strerror ( int ecode )
FUNCTION: int getaddrinfo ( c-string hostname, c-string servname, addrinfo* hints, addrinfo** res )
FUNCTION: int gethostname ( c-string name, size_t len )
FUNCTION: int getsockname ( int socket, sockaddr* address, socklen_t* address_len )
FUNCTION: int getpeername ( int socket, sockaddr* address, socklen_t* address_len )
FUNCTION: protoent* getprotobyname ( c-string name )
FUNCTION: servent* getservbyname ( c-string name, c-string proto )
FUNCTION: servent* getservbyport ( int port, c-string proto )
FUNCTION: int listen ( int s, int backlog )
FUNCTION: int shutdown ( int fd, int how )
FUNCTION: ssize_t recv ( int s, void* buf, size_t nbytes, int flags )
FUNCTION: ssize_t recvfrom ( int s, void* buf, size_t nbytes, int flags, sockaddr-in* from, socklen_t* fromlen )
FUNCTION: ssize_t sendto ( int s, void* buf, size_t len, int flags, sockaddr-in* to, socklen_t tolen )
FUNCTION: int getsockopt ( int s, int level, int optname, void* optval, socklen_t* optlen )
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen )
FUNCTION: int socket ( int domain, int type, int protocol )

! Haiku netinet/in.h exposes these four operations as compiler macros.
<PRIVATE
: haiku-network-swap16 ( n -- n' )
    dup 0xff bitand 8 shift swap -8 shift 0xff bitand bitor ; inline

: haiku-network-swap32 ( n -- n' )
    dup haiku-network-swap16 16 shift
    swap -16 shift haiku-network-swap16 bitor ; inline
PRIVATE>

: htons ( n -- n' )
    little-endian? [ haiku-network-swap16 ] [ 0xffff bitand ] if ; inline

: htonl ( n -- n' )
    little-endian? [ haiku-network-swap32 ] [ 0xffffffff bitand ] if ; inline

ALIAS: ntohs htons
ALIAS: ntohl htonl
