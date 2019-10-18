! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-api
USING: alien arrays byte-arrays kernel ;

: <wsadata> ( -- byte-array )
    HEX: 190 <byte-array> ;

: AF_INET 2 ; inline
: SOCK_STREAM 1 ; inline
: WSA_FLAG_OVERLAPPED 1 ; inline
: INADDR_ANY 0 ; inline
: INVALID_SOCKET -1 ; inline

C-STRUCT: sockaddr-in
    { "short" "family" }
    { "short" "port" }
    { "int" "addr" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" }
    { "char" "pad" } ;

C-STRUCT: hostent
    { "char*" "name" }
    { "void*" "aliases" }
    { "short" "addrtype" }
    { "short" "length" }
    { "void*" "addr-list" } ;

: hostent-addr hostent-addr-list *void* *uint ;

LIBRARY: winsock

FUNCTION: int WSAStartup ( short version, void* out-data ) ;
FUNCTION: void* WSASocketW ( int af,
                             int type,
                             int protocol,
                             void* protocol-info,
                             void* g,
                             int flags ) ;
: WSASocket WSASocketW ;

FUNCTION: ushort htons ( ushort n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;
IN: win32-api-internals
FUNCTION: int bind ( void* socket, sockaddr-in* sockaddr, int len ) ;
FUNCTION: int listen ( void* socket, int backlog ) ;
FUNCTION: char* inet_ntoa ( int in-addr ) ;
IN: win32-api
: wsa-bind bind ;
: wsa-listen listen ;
: inet-ntoa inet_ntoa ;
FUNCTION: int WSAGetLastError ( ) ;
FUNCTION: hostent* gethostbyname ( char* name ) ;
FUNCTION: int connect ( void* socket, sockaddr-in* sockaddr, int addrlen ) ;
FUNCTION: int select ( int nfds, fd_set* readfds, fd_set* writefds, fd_set* exceptfds, timeval* timeout ) ;

LIBRARY: mswsock

! Not in Windows CE
FUNCTION: bool AcceptEx ( void* listen, void* accept, void* out-buf, int recv-len, int addr-len, int remote-len, void* out-len, void* overlapped ) ;
FUNCTION: void GetAcceptExSockaddrs ( void* a, int b, int c, int d, void* e, void* f, void* g, void* h ) ;
